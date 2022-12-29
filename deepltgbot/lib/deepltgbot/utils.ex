defmodule Deepltgbot.Utils do
  alias Decimal
  alias Deepltgbot.DeeplRequests

  @thumb_url "https://cdn-icons.flaticon.com/png/512/3988/premium/3988077.png?token=exp=1652215740~hmac=3dc7d683adc86e6e9114d1b21d97054a"

  def get_progress_bar_str(ratio_progress, bar_length \\ 20, fill_char \\ "▮", empty_char \\ "▯") do
    filled_length = trunc(bar_length * ratio_progress)
    empty_length = bar_length - filled_length

    progress_bar =
      String.duplicate(fill_char, filled_length) <> String.duplicate(empty_char, empty_length)

    percentage_progress_rounded =
      (ratio_progress * 100)
      |> Decimal.from_float()
      |> Decimal.round(2)
      |> Decimal.to_float()

    _progress_bar_line = "|#{progress_bar}| #{percentage_progress_rounded}%"
  end

  def parse_languages(api_response) do
    max_name_lang_map =
      Enum.max_by(api_response, fn lang_map -> String.length(lang_map["name"]) end)

    max_name_lang_length = String.length(max_name_lang_map["name"]) + 1

    names_list =
      for lang_map <- api_response do
        lang_name = lang_map["name"]
        lang_name_filled_length = String.length(lang_name)
        empty_length = max_name_lang_length - lang_name_filled_length

        lang_name <> String.duplicate(" ", empty_length) <> "\u{27A1} "
      end

    languages_list = for lang_map <- api_response, do: lang_map["language"]

    flags_languages_list = for lang_map <- languages_list, do: lang_map <> flag_mapping(lang_map)

    arrow_languages_list =
      for lang_map <- flags_languages_list, do: Enum.join(String.split(lang_map), " \u{27A1} ")

    name_languages_zip = Enum.zip(names_list, arrow_languages_list)

    name_languages_list =
      for lang_map <- name_languages_zip, do: elem(lang_map, 0) <> elem(lang_map, 1)

    bot_response = Enum.join(name_languages_list, "\u{000A}")
    bot_response
  end

  def flag_mapping(code) do
    flags = %{
      "BG" => " \u{1F1E7}\u{1F1EC}",
      "CS" => " \u{1F1E8}\u{1F1FF}",
      "DA" => " \u{1F1E9}\u{1F1F0}",
      "DE" => " \u{1F1E9}\u{1F1EA}",
      "EL" => " \u{1F1EC}\u{1F1F7}",
      "EN" => " \u{1F1EC}\u{1F1E7}",
      "ES" => " \u{1F1EA}\u{1F1F8}",
      "ET" => " \u{1F1EA}\u{1F1EA}",
      "FI" => " \u{1F1EB}\u{1F1EE}",
      "FR" => " \u{1F1EB}\u{1F1F7}",
      "HU" => " \u{1F1ED}\u{1F1FA}",
      "ID" => " \u{1F1EE}\u{1F1E9}",
      "IT" => " \u{1F1EE}\u{1F1F9}",
      "JA" => " \u{1F1EF}\u{1F1F5}",
      "LT" => " \u{1F1F1}\u{1F1F9}",
      "LV" => " \u{1F1F1}\u{1F1FB}",
      "NL" => " \u{1F1F3}\u{1F1F1}",
      "PL" => " \u{1F1F5}\u{1F1F1}",
      "PT" => " \u{1F1F5}\u{1F1F9}",
      "RO" => " \u{1F1F7}\u{1F1F4}",
      "RU" => " \u{1F1F7}\u{1F1FA}",
      "SK" => " \u{1F1F8}\u{1F1F0}",
      "SL" => " \u{1F1F8}\u{1F1EE}",
      "SV" => " \u{1F1F8}\u{1F1EA}",
      "TR" => " \u{1F1F9}\u{1F1F7}",
      "ZH" => " \u{1F1E8}\u{1F1F3}"
    }

    if Map.has_key?(flags, code) do
      flags[code]
    else
      " Flag not available"
    end
  end

  def parse_and_translate(msg) do
    api_response_languages = DeeplRequests.get_languages()
    available_languages = for lang_map <- api_response_languages, do: lang_map["language"]

    args = String.split(msg)

    if Enum.count(args) === 0 do
      {:error,
       "To use the command use /translate <source_language> <target_language> text_to_translate"}
    else
      if Enum.member?(available_languages, String.upcase(Enum.at(args, 0))) do
        if Enum.member?(available_languages, String.upcase(Enum.at(args, 1))) do
          source_language = String.upcase(Enum.at(args, 0))
          target_language = String.upcase(Enum.at(args, 1))

          args = List.delete_at(args, 0)
          args = List.delete_at(args, 0)

          text_to_translate = Enum.join(args, " ")

          api_response =
            DeeplRequests.translate(text_to_translate, source_language, target_language)

          get_translation_result(api_response, text_to_translate, source_language, target_language)
        else
          target_language = String.upcase(Enum.at(args, 0))

          args = List.delete_at(args, 0)

          text_to_translate = Enum.join(args, " ")

          api_response = DeeplRequests.translate(text_to_translate, target_language)

          get_translation_result(api_response, text_to_translate, target_language)
        end
      else
        {:error,
         """
           Languages not recognized.
         Use /showlanguages to know which languages are supported.
         """}
      end
    end
  end

  def get_translation_result(api_response, text_to_translate, target_language) do
    translation_map = Enum.at(api_response["translations"], 0)
    translation = translation_map["text"]

    source_language = translation_map["detected_source_language"] |> String.upcase()

    {:ok,
     %{
       text_to_translate: text_to_translate,
       translation: translation,
       source_language: source_language,
       target_language: target_language
     }}
  end

  def get_translation_result(api_response, text_to_translate, source_language, target_language) do
    translation_map = Enum.at(api_response["translations"], 0)
    translation = translation_map["text"]

    {:ok,
     %{
       text_to_translate: text_to_translate,
       translation: translation,
       source_language: source_language,
       target_language: target_language
     }}
  end

  def parse_translation_result(translation_result) do
    case translation_result do
      {:ok, result} ->
        _response = """
        Translating #{inspect(result.text_to_translate)} from #{flag_mapping(result.source_language)} to #{flag_mapping(result.target_language)}...
        #{result.translation}
        """

      {:error, msg} ->
        _response = msg
    end
  end

  def get_query_result(translation_result, id \\ 0) do
    case translation_result do
      {:error, _} ->
        :error

      {:ok, result} ->
        _query_result = %ExGram.Model.InlineQueryResultArticle{
          type: "article",
          id: "#{id}",
          title:
            "Translating from #{flag_mapping(result.source_language)} to #{flag_mapping(result.target_language)}...",
          description: result.translation,
          input_message_content: %ExGram.Model.InputTextMessageContent{
            message_text: result.translation
          },
          thumb_url: @thumb_url
        }
    end
  end
end
