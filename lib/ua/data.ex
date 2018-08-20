defmodule UA.Data do
  # @atoms [
  #   :namespace, :user_agent_parsers,  :os_parsers, :device_parsers,
  #   :regex, :regex_flag, :family_replacement, :v1_replacement, :v2_replacement,
  #   :os_replacement, :os_v1_replacement, :os_v2_replacement, :os_v3_replacement,
  #   :device_replacement, :brand_replacement, :model_replacement
  # ]

  def  convert_to_atom_map(map), do: to_atom_map(map)

  defp to_atom_map(map) when is_map(map), do: Map.new(map, fn {k,v} -> {String.to_atom(k),to_atom_map(v)} end)
  defp to_atom_map(list) when is_list(list), do: Enum.map(list, fn(i) -> to_atom_map(i) end)
  defp to_atom_map(v), do: v

  def preload do
    data = Path.join([File.cwd!, "vendor/", "uap-core", "regexes.yaml"])
      |> YamlElixir.read_from_file!
      |> to_atom_map

    data
    |> Map.put(:user_agent_parsers, compile_regexps(data[:user_agent_parsers]))
    |> Map.put(:os_parsers, compile_regexps(data[:os_parsers]))
    |> Map.put(:device_parsers, compile_regexps(data[:device_parsers]))
  end

  defp compile_regexps(parsers) do
    parsers
    |> Enum.map(fn(parser) ->
      parser
      |> Map.put(:regex, Regex.compile!(parser[:regex], parser[:regex_flag] || ""))
      |> Map.delete(:regex_flag)
    end)
  end
end
