defmodule Deepltgbot.DeeplRequests do
  use Tesla

  plug(Tesla.Middleware.BaseUrl, "https://api-free.deepl.com/v2")

  plug(Tesla.Middleware.Headers, [
    {"Authorization", "DeepL-Auth-Key #{System.get_env("DEEPL_TOKEN")}"}
  ])

  plug(Tesla.Middleware.FormUrlencoded)

  def translate(text, source_lang, target_lang) do
    response_tuple =
      post("/translate", %{text: text, source_lang: source_lang, target_lang: target_lang})

    check_and_decode(response_tuple)
  end

  def translate(text, target_lang) do
    response_tuple = post("/translate", %{text: text, target_lang: target_lang})

    check_and_decode(response_tuple)
  end

  defp check_and_decode(response_tuple) do
    case response_tuple do
      {:ok, response} ->
        if response.status !== 200 do
          :error
        else
          decode_response(response)
        end

      {:error, _response_error} ->
        :error
    end
  end

  defp decode_response(response) do
    decoded_response_tuple = Jason.decode(response.body)

    case decoded_response_tuple do
      {:ok, response_decoded} ->
        response_decoded

      {:error, _decode_error} ->
        :error
    end
  end
end
