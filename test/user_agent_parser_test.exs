defmodule UserAgentParserTest do
  use ExUnit.Case
  doctest UserAgentParser

  # test "browser detection" do
  #   Path.join([File.cwd!, "vendor/", "uap-core", "tests", "test_ua.yaml"])
  #       |> YamlElixir.read_from_file!
  #       |> Map.get("test_cases")
  #       |> Enum.map(fn(test_case) ->
  #         uap = UserAgentParser.detect_browser(test_case["user_agent_string"])
  #         assert uap.family == test_case["family"]
  #         assert uap.major == test_case["major"]
  #         assert uap.minor == test_case["minor"]
  #         assert uap.patch == test_case["patch"]
  #       end)
  # end
  #
  test "OS detection" do
    Path.join([File.cwd!, "vendor/", "uap-core", "tests", "test_os.yaml"])
        |> YamlElixir.read_from_file!
        |> Map.get("test_cases")
        |> Enum.map(fn(test_case) ->
          uap = UserAgentParser.detect_os(test_case["user_agent_string"])
          assert uap.family == test_case["family"]
          assert uap.major == test_case["major"]
          assert uap.minor == test_case["minor"]
          assert uap.patch == test_case["patch"]
          assert uap.patch_minor == test_case["patch_minor"]
        end)
  end

  test "device detection" do
    Path.join([File.cwd!, "vendor/", "uap-core", "tests", "test_device.yaml"])
      |> YamlElixir.read_from_file!
      |> Map.get("test_cases")
      |> Enum.map(fn(test_case) ->
        uap = UserAgentParser.detect_device(test_case["user_agent_string"])
        assert uap.family == test_case["family"]
      end)
  end
end
