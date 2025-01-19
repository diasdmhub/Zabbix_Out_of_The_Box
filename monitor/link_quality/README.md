| [↩️ Back](../) |
| --- |

# Link Quality by Simple Check Zabbix Template

<div align="right">

[![License](https://img.shields.io/badge/License-GPL3-blue?logo=opensourceinitiative&logoColor=fff)](./../../LICENSE)
[![Version](https://img.shields.io/badge/Version-722-blue?logo=zotero&color=0aa8d2)](./link_quality_template_v722.yaml)

</div>

<BR>

## OVERVIEW

This template provides a method for checking the reliability of multiple links. It provides simple ICMP items that give an overview of a link's connectivity, performance, and degradation. These indicators provide a basic measure of the quality and reliability of the target link. It is based on the OOTB "_ICMP Ping_" template and enhanced to receive a list of ICMP targets.

A manual address list is configured to obtain the ICMP destinations, then Zabbix sends the list to an LLD rule which dynamically creates simple ICMP items for each address. It was designed primarily for Internet addresses, but can be used for most types of links, such as WAN, LAN and VPN.

<BR>

### REQUIREMENTS

- Since the discovered items are Simple Checks, the Zabbix Server/Proxy must be allowed to ping the destination target.
- If DNS names are used, the Zabbix Server/Proxy must be able to resolve them.

<BR>

### SETUP

1. The template's `{$ICMP.ADDRESS.LIST}` macro is empty by default and is intended for host-level configuration.
2. ⚠️ Configure the `{$ICMP.ADDRESS.LIST}` macro with IPs or DNS addresses separated by commas (`,`).
    - **Example**: `1.2.3.4,5.6.7.8,target.domain,public.com`
3. The master item is updated once a day to reflect any changes in the host macro.
    - If the macro is changed, it is possible to run the "_Execute Now_" command and update the list. This executes the discovery rule.

> Below are some of the major BigTech domains commonly used to test Internet connectivity.

> - Google - `connectivitycheck.gstatic.com`
> - Cloudflare - `engage.cloudflareclient.com`
> - Microsoft - `internetbeacon.msedge.net`

> 💡 _I'm looking for more BigTech **public** addresses that are specific for conectivity checks, like captive portal or beacon addresses. (Amazon, Apple, banks, Cisco, Meta, Netflix, NVidia, Tesla, etc)_

<BR>

---
### ➡️ [Download](./link_quality_template_v722.yaml)
---
#### ➡️ [*How to import templates*](https://www.zabbix.com/documentation/current/en/manual/xml_export_import/templates#importing)
---

<BR>

## MACROS USED

| Macro                | Default Value | Description |
| :------------------- | :-----------: | :---------- |
| {$ICMP.ADDRESS.LIST} |               | Comma-separated list of ICMP destination addresses. DNS names are valid if your Zabbix Server can resolve them. |
| {$ICMP.LATENCY.WARN} | `0.15`        | ICMP RTT latency warning timeout in seconds. |
| {$ICMP.LOSS.WARN}    | `25`          | ICMP packet loss percentage for warning threshold. Default of 4 packets sent gives a rounding rate of 25, 50, 75 or 100. |
| {$ICMP.REPEAT.COUNT} | `4`           | Number of ICMP packets sent to the destination address. |
| {$ICMP.TIMEOUT}      | `200`         | RTT timeout of each ICMP packet in miliseconds. |

> **The default values can be very conservative and sensitive, and it is recommended that you customize them for your own environment.**

<BR>

## ITEMS

| Name               | Description |
| :----------------- | :---------- |
| ICMP Address List  | This item takes a comma-separated list of ICMP destination addresses and converts it to a JSON array. This array is used by the ICMP Address Discovery rule to dynamically create items. |

<BR>

## DISCOVERY RULE

| Name                   | Description |
| ---------------------- | :---------- |
| ICMP Address Discovery | This LLD takes the master item JSON array of ICMP destination addresses and converts it to an LLD JSON array. This array is looped through to dynamically create host items for each address in the array. |

<BR>

## ITEM PROTOTYPES

| Name                                      | Description |
| :---------------------------------------- | :---------- |
| ICMP Jitter from `{#ICMP.ADDRESS}`        | ICMP response time variation from the destination address `{#ICMP.ADDRESS}` taking into account previous and latest value |
| ICMP Loss from `{#ICMP.ADDRESS}`          | ICMP percentage of packets lost from the destination address `{#ICMP.ADDRESS}` |
| ICMP Response Time from `{#ICMP.ADDRESS}` | ICMP response time in seconds from the destination address `{#ICMP.ADDRESS}` |

<BR>

## TRIGGER PROTOTYPES

| Name                                           | Description |
| :--------------------------------------------- | :---------- |
| `{#ICMP.ADDRESS}` High ICMP loss               | Last and previous ICMP ping attempts returned at least `{$ICMP.LOSS.WARN}`% of packet loss, or the latest ICMP ping attempt returned more than `{$ICMP.LOSS.WARN}`% packet loss. |
| `{#ICMP.ADDRESS}` High ICMP ping response time | The last ICMP ping response time was higher than `{$ICMP.LATENCY.WARN}`s |
| `{#ICMP.ADDRESS}` Unavailable by ICMP ping     | The last two ICMP ping attempts to `{#ICMP.ADDRESS}` have timed out. |

<BR>

## GRAPH PROTOTYPE

| Name                                           |
| :--------------------------------------------- |
| ICMP Ping Response Time from `{#ICMP.ADDRESS}` |

<BR>

## DASHBOARD EXAMPLE

![Zabbix Link Quality Dashboard](./image/dashboard_sample.png)

<BR>

| [⬆️ Top](#link-quality-by-simple-check-zabbix-template) |
| --- |