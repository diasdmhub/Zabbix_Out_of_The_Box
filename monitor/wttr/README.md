| [↩️ Back](../) |
| --- |

# Zabbix WTTR.in Template

<div align="right">

[![License](https://img.shields.io/badge/License-GPL3-blue?logo=opensourceinitiative&logoColor=fff)](./../../LICENSE) [![Version](https://img.shields.io/badge/Version-721-blue?logo=zotero&color=0aa8d2)](./zabbix_housekeeper_template_v705.yaml)

</div>

<BR>

## OVERVIEW

[WTTR.in](https://wttr.in) is a "_console-oriented weather forecast service that supports various information representation methods_". This is a Zabbix template that pulls weather information from WTTR.in for specific locations.

The data is retrieved in JSON format and stored in various items.

For more information, see [WTTR Help](https://wttr.in/:help) and [WTTR GitHub's](https://github.com/chubin/wttr.in).

<BR>

### Requirements

- It is suggested to create a host for each location and [set the host interface](https://www.zabbix.com/documentation/current/en/manual/config/hosts/host) as the WTTR DNS address, something like `wttr.in`, or your own instance.

<BR>

---
### ➡️ [Download](./wttr_http_template_v721.yaml)
---
#### ➡️ [*How to import templates*](https://www.zabbix.com/documentation/current/en/manual/xml_export_import/templates#importing)
---

<BR>

## MACROS USED

| Macro              | Default Value | Description |
| :----------------- | :-----------: | :---------- |
| `{$WTTR_LANGUAGE}` | en            | Available languages: [](https://wttr.in/:translation) |
| `{$WTTR_LOCATION}` |               | Place your location here. If empty, IP will be used to track the location. Multiple locations may be separated by comma. [`Latitude`,`Longitude`] supported. |
| `{$WTTR_UNIT}`     | m             | Unit types: `m`=metric (default), `u`=USCS, `M`=metric with m/s |

<BR>

## ITEMS

| Name                                         | Description |
| :------------------------------------------- | :---------- |
| WTTR JSON                                    | WTTR raw JSON data for the provided location |
| WTTR JSON: Humidity                          | WTTR humidity estimates for the provided location |
| WTTR JSON: Temperature Average Celsius       | WTTR average temperature in Celsius for the provided location |
| WTTR JSON: Temperature Average Fahrenheit    | WTTR average temperature in Fahrenheit for the provided location |
| WTTR JSON: Temperature Celsius               | WTTR temperature in Celsius for the provided location |
| WTTR JSON: Temperature Fahrenheit            | WTTR temperature in Fahrenheit for the provided location |
| WTTR JSON: Temperature Feels Like Celsius    | WTTR Feels Like temperature in Celsius for the provided location |
| WTTR JSON: Temperature Feels Like Fahrenheit | WTTR Feels Like temperature in Fahrenheit for the provided location |
| WTTR JSON: UV Index                          | WTTR UV Index for the provided location |
| WTTR JSON: `{$WTTR_LOCATION}` Latitude       | The nearest latitude for the provided location, `{$WTTR_LOCATION}` |
| WTTR JSON: `{$WTTR_LOCATION}` Longitude      | The nearest longitude for the provided location, `{$WTTR_LOCATION}` |

<BR>

## TRIGGERS

| Name               | Description |
| :----------------- | :---------- |
| UV Index High      | UV Index is High at the provided location |
| UV Index Very High | UV Index is very high at the provided location |

<BR>

## DASHBOARD EXAMPLE

![Zabbix WTTR Dashboard](./image/wttr_dashboard_sample.png)

<BR>

| [⬆️ Top](#zabbix-wttr-template) |
| --- |