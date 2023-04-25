defmodule Testly.SessionRecordings.DeviceTest do
  use Testly.DataCase, async: true

  alias Testly.SessionRecordings.Device
  alias Ecto.Changeset

  describe "create_changeset/2" do
    test "detects phablets" do
      ch =
        Device.create_changeset(%Device{}, %{
          user_agent:
            "Mozilla/5.0 (iPhone; CPU iPhone OS 12_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/16B92 [FBAN/FBIOS;FBAV/198.0.0.57.101;FBBV/131415284;FBDV/iPhone9,2;FBMD/iPhone;FBSN/iOS;FBSV/12.1;FBSS/3;FBCR/Carrier;FBID/phone;FBLC/en_GB;FBOP/5;FBRV/132034190]"
        })

      assert Changeset.get_field(ch, :type) === :mobile
    end

    test "unknown client" do
      ch =
        Device.create_changeset(%Device{}, %{
          user_agent: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_6) AppleWebKit/605.1.15 (KHTML, like Gecko)"
        })

      assert Changeset.get_field(ch, :browser_name) === nil
      assert Changeset.get_field(ch, :browser_version) === nil
    end

    test "unknown os" do
      ch =
        Device.create_changeset(%Device{}, %{
          user_agent:
            "[FBAN/FB4A;FBAV/136.0.0.22.91;FBBV/67437982;FBDM/{density=2.0,width=720,height=1192};FBLC/en_GB;FBRV/68190457;FBCR/Ooredoo;FBMF/HUAWEI;FBBD/HUAWEI;FBPN/com.facebook.katana;FBDV/MYA-L22;FBSV/6.0;FBOP/19;FBCA/armeabi-v7a:armeabi;]"
        })

      assert Changeset.get_field(ch, :os_name) === nil
      assert Changeset.get_field(ch, :os_version) === nil
    end
  end
end
