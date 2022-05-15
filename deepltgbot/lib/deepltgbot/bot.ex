defmodule Deepltgbot.Bot do
  alias Deepltgbot.{DeeplRequests, Utils}

  @bot :deepltgbot

  use ExGram.Bot,
    name: @bot,
    setup_commands: true

  command("start")
  command("help", description: "Show bot help")
  command("showlanguages", description: "Show languages availables for translation")

  middleware(ExGram.Middleware.IgnoreUsername)

  def bot(), do: @bot

  def handle({:command, :start, msg}, context) do
    handle({:command, :help, msg}, context)
  end

  def handle({:command, :help, _msg}, context) do
    answer(context, """
    Hello! \u{1F600} Welcome to the DeepL Bot
    Use /showlanguages to see the available languages for translation
    Use /translate source_language target_language text to translate the text from source_language to target_language
    Use /translate target_language text to translate the text to target_language detecting the source_language
    """)
  end

  def handle({:command, :showlanguages, _msg}, context) do
    api_response = DeeplRequests.get_languages()

    bot_response = Utils.parse_languages(api_response)

    answer(context, """
    AVAILABLE LANGUAGES:
    #{bot_response}
    """)
  end
end
