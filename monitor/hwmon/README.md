| [↩️ Back](../) |
| --- |

# Linux Hwmon Sensors Zabbix Template by Agent Active

<div align="right">

[![License](https://img.shields.io/badge/License-GPL3-blue?logo=opensourceinitiative&logoColor=fff)][license]
[![Version](https://img.shields.io/badge/Version-7415-blue?logo=zotero&color=0aa8d2)][template_file]

</div>

<BR>

## OVERVIEW

Linux exposes hardware sensors through the kernel's [**hwmon**][hwmon] subsystem. Each sensor driver registers its readings under `/sys/devices` as `temp*_input` files. Examples of sensor drivers include `k10temp` for AMD CPUs, `coretemp` for Intel CPUs, `amdgpu`, `nvme` or `spd5118` for DDR5 modules.

Many monitoring setups read CPU temperatures from `/sys/devices/virtual/thermal/thermal_zone*/temp`. This method works on most Intel hosts, where the `x86_pkg_temp` thermal zone exists. However, on AMD hosts, however, the CPU driver only registers an hwmon device, not thermal zone. The remaining zones typically originate from the BIOS ACPI tables (`acpitz`), which often report a fixed value, or from devices, such as Wi-Fi cards, that may be unreadable.

This template discovers every hwmon temperature sensor on a Linux host using only native Zabbix Agent keys. No `UserParameter`, sudo rule, or `lm-sensors` package is required. As devices change, the monitoring updates automatically.

<BR>

## TEMPLATES

- ⬇️ [`Linux Hwmon Sensors by Zabbix Agent Active`](#-template-linux-hwmon-sensors-by-zabbix-agent-active)

<BR>

## REQUIREMENTS

- A Linux host with `/sys` mounted (usually any kernel with hwmon support).
- Zabbix Agent or Zabbix Agent 2.
    - `ServerActive` must point to the Zabbix server or proxy.
- The agent user only needs read access to `/sys/devices`, which is world-readable by default.

> **This template is configured for "active checks", but the LLD and item prototypes can be reverted to passive checks if necessary.**

<BR>

## TEST VERSION

Tested with AMD and Intel hosts running Zabbix Agent 2.

- AMD Ryzen 9 7940HS (`k10temp`)
- Intel Core i5-14500T (`coretemp`)

**Since there is a large variety of devices and drivers available, more testing is recommended.**

<BR>

---
### ➡️ [Download (releases)][template_file]
---
#### ➡️ [_How to import templates_][import_templates]
---

<BR>

## HOW IT WORKS

1. The discovery rule runs the `vfs.dir.get[/sys/devices,"{$HWMON.TEMP.INPUT.FILE}",,file]` Agent key. It returns every hwmon temperature file with its full device path. For example, it might return `/sys/devices/pci0000:00/0000:00:18.3/hwmon/hwmon4/temp1_input`.
2. A JavaScript preprocessing step classifies each file by device type and device name, using the bus address found in the path.
3. Each sensor receives an item that reads the file using the `vfs.file.contents` key. The kernel reports millidegrees, which are converted to degrees Celsius.
4. Each hwmon device also receives a `Device Name` item that reads the driver name from the `name` file in the same directory.

### DEVICE TYPES

| Type       | Device                                       | `{#DEVICE}` example |
| ---------- | -------------------------------------------- | ------------------- |
| `cpu`      | AMD CPU (`k10temp`, PCI `00:18.3`) or Intel CPU (`coretemp`) | `00:18.3`, `coretemp.0` |
| `nvme`     | NVMe drive                                   | `nvme0`             |
| `i2c`      | I2C device, such as a DDR5 SPD hub           | `i2c-0-50`          |
| `pci`      | Other PCI device, such as `amdgpu` or `i915` | `c5:00.0`           |
| `mdio`     | Network PHY on an MDIO bus, such as `r8169`  | `02:00.0`           |
| `wmi`      | ACPI WMI firmware device, such as `dell_smm`, `dell_ddv` or `asus_wmi_sensors`. Named after the first block of its WMI GUID | `wmi-F1DDEE52` |
| `platform` | Platform device, such as a Super I/O chip    | `nct6775.656`       |
| `thermal`  | ACPI (`acpitz`) or device thermal zone. **Filtered out by default** | `thermal_zone0` |
| `other`    | Anything else                                | Last component of the device path |

<BR>

## LIMITATIONS

- This template has a limited scope. It only discovers sensors that are registered in the hwmon subsystem, specifically the `temp*_input` located in an `hwmonN` directory. It does not handle all types of kernel devices. For instance, it ignores raw thermal zone files, such as `/sys/devices/virtual/thermal/thermal_zone0/temp`. Some kernels, which are common on ARM boards and in some minimal builds, do not register thermal zones as hwmon devices. Therefore, hosts that expose temperatures only through thermal zones will have nothing discovered.
- Item keys contain the `hwmonN` directory. If the kernel renumbers hwmon devices after rebooting, new items are created, and old items are removed after the lost resources period (`5d`). The history data is split, but it never mixes between sensors, because the key also contains the full device path.
- Item names use the device type and device name rather than the driver name or the sensor label (e.g., `Tctl` or `Composite`). These values are stored in files, but the LLD cannot read file contents into macros. The `Device Name` item records the driver name instead.
- The native `sensor[]` key was not used, because it often requires the exact `lm-sensors` device name and does not always accept a regular expressions for the chip name. Additionally, some tests showed that it cannot read NVMe or MDIO sensors.

<BR>

---

<BR>

## 🔶 Template `Linux Hwmon Sensors by Zabbix Agent Active`

### MACROS

| Macro                          | Default Value      | Description |
| ------------------------------ | :----------------: | ----------- |
| `{$HWMON.DEVICE.MATCHES}`      | `.*`               | Filters **only** devices that match this regex. For example `00:18.3`, `nvme0`, `i2c-0-50` or `coretemp.0` |
| `{$HWMON.DEVICE.NOT_MATCHES}`  | `CHANGE_IF_NEEDED` | Filters **out** devices that match this regex |
| `{$HWMON.DEVTYPE.MATCHES}`     | `.*`               | Filters **only** device types that match this regex |
| `{$HWMON.DEVTYPE.NOT_MATCHES}` | `^thermal$`        | Filters **out** device types that match this regex. Thermal zones are filtered out by default because ACPI zones are often fake and device zones can be unreadable |
| `{$HWMON.TEMP.CRIT}`           | `90`               | Critical temperature threshold in degrees Celsius. Can be used with the device type as context |
| `{$HWMON.TEMP.CRIT:"cpu"}`     | `95`               | Critical temperature threshold for CPUs |
| `{$HWMON.TEMP.CRIT:"i2c"}`     | `85`               | Critical temperature threshold for I2C sensors, such as DDR5 SPD hubs |
| `{$HWMON.TEMP.CRIT:"nvme"}`    | `80`               | Critical temperature threshold for NVMe drives |
| `{$HWMON.TEMP.INPUT.FILE}`     | `^temp\d+_input$`  | Regex used by the discovery key to filter only files that provide temperature values |
| `{$HWMON.TEMP.WARN}`           | `80`               | Warning temperature threshold in degrees Celsius. Can be used with the device type as context |
| `{$HWMON.TEMP.WARN:"cpu"}`     | `85`               | Warning temperature threshold for CPUs |
| `{$HWMON.TEMP.WARN:"i2c"}`     | `75`               | Warning temperature threshold for I2C sensors, such as DDR5 SPD hubs |
| `{$HWMON.TEMP.WARN:"nvme"}`    | `70`               | Warning temperature threshold for NVMe drives |

> ℹ️ **Thresholds for other device types, such as `pci` or `mdio`, can be added with a context macro. For example, `{$HWMON.TEMP.CRIT:"pci"}`.**

<BR>

### ➡️ DISCOVERY RULE `Discovery Hwmon Temperature`

> **Discovers hwmon temperature sensors below `/sys/devices`**

<BR>

#### ITEM PROTOTYPES

| Name                                                | Description |
| --------------------------------------------------- | ----------- |
| `{#DEVTYPE} {#DEVICE} {#SENSOR}` - Temperature      | The temperature reading of the sensor in degrees Celsius |
| `{#DEVTYPE} {#DEVICE}` - Device Name                  | The hwmon driver name of the device, such as `k10temp` or `amdgpu`. Created once per hwmon device by an LLD override |

<BR>

#### TRIGGER PROTOTYPES

| Name                                                                       | Description |
| -------------------------------------------------------------------------- | ----------- |
| `{#DEVTYPE} {#DEVICE} {#SENSOR}` - Temperature is Above Critical Threshold | Indicates that the sensor temperature has stayed above critical threshold for 5 minutes |
| `{#DEVTYPE} {#DEVICE} {#SENSOR}` - Temperature is Above Warning Threshold  | Indicates that the sensor temperature has stayed above warning threshold for 5 minutes |

<BR>

| [⬆️ Top](#linux-hwmon-sensors-zabbix-template-by-agent-active) |
| --- |

[hwmon]: https://docs.kernel.org/hwmon/index.html
[template_file]: ./linux_hwmon_template_v7415.yaml
[import_templates]: https://www.zabbix.com/documentation/current/en/manual/xml_export_import/templates#importing
[license]: ./../../LICENSE