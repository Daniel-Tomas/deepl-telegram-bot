defmodule Deepltgbot.Bot do
  alias Deepltgbot.{DeeplRequests, Utils, TranslateSupervisor}

  @bot :deepltgbot

  use ExGram.Bot,
    name: @bot,
    setup_commands: true

  command("start")
  command("help", description: "Show bot help")
  command("getusage", description: "Show DeepL API usage")
  command("showlanguages", description: "Show languages availables for translation")
  command("translate", description: "Translates given text from one language to another")

  middleware(ExGram.Middleware.IgnoreUsername)

  def bot(), do: @bot

  def handle({:command, :start, msg}, context) do
    handle({:command, :help, msg}, context)
  end

  def handle({:command, :help, _msg}, context) do
    bot_username = ExGram.get_me!(bot: @bot).username

    answer_str = """
    Hello! \u{1F600} Welcome to the DeepL Bot
    Use "/showlanguages" to see the available languages for translation
    Use "/getusage" to see the DeepL API usage

    Use "/translate source_language target_language text"\nto translate the text from source_language to target_language
    Use "/translate target_language text"\nto translate the text to target_language detecting the source_language

    To use translation in any chat write \n"@#{bot_username} source_language target_language text"\nto translate the text from source_language to target_language
    To use translation in any chat write \n"@#{bot_username} target_language text"\nto translate the text to target_language detecting the source_language
    """

    answer(
      context,
      answer_str
    )
  end

  def handle({:command, :getusage, _msg}, context) do
    api_response = DeeplRequests.get_usage()

    ratio_progress = api_response["character_count"] / api_response["character_limit"]

    answer_str = """
    DeepL API usage:
    #{Utils.get_progress_bar_str(ratio_progress)}
    """

    answer(
      context,
      answer_str
    )
  end

  def handle({:command, :showlanguages, _msg}, context) do
    api_response = DeeplRequests.get_languages()

    bot_response = Utils.parse_languages(api_response)

    answer_str = """
    ```
    Available languages:
    #{bot_response}
    ```
    """

    answer(
      context,
      answer_str,
      parse_mode: "MarkdownV2"
    )
  end

  def handle({:command, :translate, %{text: msg}}, context) do
    TranslateSupervisor.start_link([msg, context])
  end

  def async_translate(msg, context) do
    translation_result = Utils.parse_and_translate(msg)
    response = Utils.parse_translation_result(translation_result)

    if not is_nil(context.update) and Map.has_key?(context.update, :message) do
      ExGram.send_message(context.update.message.chat.id, response, bot: @bot)
    end
  end

  def handle({:inline_query, inline_query}, context) do
    msg = inline_query.query
    translation_result = Utils.parse_and_translate(msg)

    case Utils.get_query_result(translation_result) do
      :error ->
        nil

      translation_query_result ->

        api_response = DeeplRequests.translate(translation_result.translation, translation_result.target_language, translation_result.source_language)
        translation_result_reversed = Utils.get_translation_result(api_response,translation_result.translation, translation_result.target_language, translation_result.source_language)

        case Utils.get_query_result(translation_result_reversed) do
          :error ->
            nil

          translation_query_result_reversed ->
            results = [translation_query_result,translation_query_result_reversed]
            answer_inline_query(context, results)
          end
    end
  end

  def handle(_, _), do: nil
end
