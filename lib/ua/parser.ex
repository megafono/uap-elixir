[defmodule UA.Parser do
  use GenServer

  def init(args) do
    {:ok, args}
  end

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def parse(user_agent) do
    GenServer.call(__MODULE__, {:parse, user_agent})
  end

  def detect_browser(user_agent) do
    GenServer.call(__MODULE__, {:detect_browser, user_agent})
  end

  def detect_os(user_agent) do
    GenServer.call(__MODULE__, {:detect_os, user_agent})
  end

  def detect_device(user_agent) do
    GenServer.call(__MODULE__, {:detect_device, user_agent})
  end

  @data UA.Data.preload
  defp data do
    @data
  end

  def handle_call({:parse, ua}, _from, state) do
    browser = do_detect_browser(ua)
    os = do_detect_os(ua)
    device = do_detect_device(ua)
    {:reply, {browser, os, device}, state}
  end

  def handle_call({:detect_browser, ua}, _from, state) do
    {:reply, do_detect_browser(ua), state}
  end

  def handle_call({:detect_os, ua}, _from, state) do
    {:reply, do_detect_os(ua), state}
  end

  def handle_call({:detect_device, ua}, _from, state) do
    {:reply, do_detect_device(ua), state}
  end

  defp do_detect_browser(ua) do
    data()[:user_agent_parsers]
    |> Enum.find(fn(%{regex: regex}) -> Regex.run(regex, ua) end)
    |> parse_browser(ua)
  end

  defp parse_browser(nil, _), do: %UA.Browser{ }
  defp parse_browser(parser, ua) do
    family_repl = parser[:family_replacement]
    v1_repl = parser[:v1_replacement]
    v2_repl = parser[:v2_replacement]
    v3_repl = parser[:v3_replacement]
    version = [v1_repl, v2_repl] |> Enum.filter(&(&1 != nil)) |> version_from_parts

    case Regex.run(parser[:regex], ua) do
      [_, family | ver_parts] ->
        %UA.Browser{
          family: String.replace(family_repl || family, "$1", family),
          major: nil,
          minor: nil,
          patch: nil
          # version: version || version_from_parts(ver_parts)
        }
      [_] ->
        %UA.Browser{
          family: family_repl,
          version: version
        }
    end
  end

  def do_detect_os(ua) do
    data()[:os_parsers]
    |> Enum.find(fn(%{regex: regex}) -> Regex.run(regex, ua) end)
    |> parse_os(ua)
  end

  defp parse_os(nil, _), do: %UA.OS{ }
  defp parse_os(parser, ua) do
    [ _ | matches ] = Regex.run(parser[:regex], ua)

    family = (parser[:os_replacement] || matches |> Enum.at(0, ""))
              |> String.replace("$1", matches |> Enum.at(0, ""))

    major = (parser[:os_v1_replacement] || Enum.at(matches, 1, ""))
              |> String.replace("$1", matches |> Enum.at(0, ""))
              |> String.replace("$2", matches |> Enum.at(1, ""))

    minor = (parser[:os_v2_replacement] || Enum.at(matches, 2, ""))
              |> String.replace("$3", matches |> Enum.at(2, ""))

    patch = (parser[:os_v3_replacement] || Enum.at(matches, 3, ""))
              |> String.replace("$4", matches |> Enum.at(3, ""))

    patch_minor = (parser[:os_v4_replacement] || Enum.at(matches, 4, ""))
              |> String.replace("$5", matches |> Enum.at(4, ""))

    %UA.OS {
      family: family,
      major: (if (major == ""), do: nil, else: major),
      minor: (if (minor == ""), do: nil, else: minor),
      patch: (if (patch == ""), do: nil, else: patch),
      patch_minor: (if (patch_minor == ""), do: nil, else: patch_minor),
    }
  end

  def do_detect_device(ua) do
    data()[:device_parsers]
    |> Enum.find(fn(%{regex: regex}) -> Regex.run(regex, ua) end)
    |> parse_device(ua)
  end

  defp parse_device(nil, _), do: %UA.Device{ }
  defp parse_device(parser, ua) do
    IO.inspect(parser)
    IO.inspect(ua)

    substitutions = case Regex.run(parser[:regex], ua) do
      [_, device, brand, model] -> [{"$1", device}, {"$2", brand}, {"$3", model}]
      [_, device, brand] -> [{"$1", device}, {"$2", brand}]
      [_, device] -> [{"$1", device}]
      [_] -> []
    end
    %UA.Device{
      family: make_substitutions(parser[:device_replacement], substitutions),
      brand: make_substitutions(parser[:brand_replacement], substitutions),
      model: make_substitutions(parser[:model_replacement], substitutions)
    }
  end

  defp version_from_parts([]), do: nil
  defp version_from_parts(parts), do: Enum.join(parts, ".")

  defp make_substitutions(:unknown, _), do: nil
  defp make_substitutions(nil, _), do: nil
  defp make_substitutions(string, substitutions) do
    substitutions |> Enum.reduce(string, fn({k, v}, string) ->
      String.replace(string, k, v)
    end) |> String.trim
  end
end
]
