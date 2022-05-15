defmodule Deepltgbot.Utils do
  alias Deepltgbot.DeeplRequests

  def parse_languages(api_response) do
    names_list = for map <- api_response, do: map["name"] <> " \u{27A1} "
    languages_list = for map <- api_response, do: map["language"]
    flags_languages_list = for map <- languages_list, do: map <> flag_mapping()[map]

    arrow_languages_list =
      for map <- flags_languages_list, do: Enum.join(String.split(map), " \u{27A1} ")

    name_languages_zip = Enum.zip(names_list, arrow_languages_list)
    name_languages_list = for map <- name_languages_zip, do: elem(map, 0) <> elem(map, 1)
    bot_response = Enum.join(name_languages_list, "\u{000A}")
    bot_response
  end

  def flag_mapping do
    %{
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
      "ZH" => " \u{1F1E8}\u{1F1F3}"
    }
  end
end
