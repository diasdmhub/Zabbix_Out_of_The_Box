| [↩️ Back](../) |
| --- |

# Zabbix Housekeeper Stats Template

<div align="right">

[![License](https://img.shields.io/badge/License-GPL3-blue?logo=opensourceinitiative&logoColor=fff)](./../../LICENSE) [![Version](https://img.shields.io/badge/Version-722-blue?logo=zotero&color=0aa8d2)](./zabbix_housekeeper_template_v722.yaml)

</div>

<BR>

## OVERVIEW

This is a simple template that checks the records deleted by the Housekeeper process and its execution time.

<BR>

### Requirements

- Active Zabbix Agent in the Zabbix Server host.

<BR>

---
### ➡️ [Download](./zabbix_housekeeper_template_v722.yaml)
---
#### ➡️ [*How to import templates*](https://www.zabbix.com/documentation/current/en/manual/xml_export_import/templates#importing)
---

<BR>

## MACROS USED

| Macro                    | Default Value | Description |
| :----------------------- | :-----------: | :---------- |
| {$HOUSEKEEPER.EXEC.WARN} | 60            | Time limit in seconds for Housekeeper execution time warning |

<BR>

## ITEMS

| Name |
| :--- |
| Housekeeper Log Statistics |
| Housekeeper Log Statistics: Alarm Records Deleted |
| Housekeeper Log Statistics: Audit Records Deleted |
| Housekeeper Log Statistics: Autoregistration Host Records Deleted |
| Housekeeper Log Statistics: Event Records Deleted |
| Housekeeper Log Statistics: Execution Time |
| Housekeeper Log Statistics: History and Trend Records Deleted |
| Housekeeper Log Statistics: Item and Trigger Records Deleted |
| Housekeeper Log Statistics: Problem Records Deleted |
| Housekeeper Log Statistics: Records Deleted |
| Housekeeper Log Statistics: Session Records Deleted |

<BR>

## TRIGGERS

| Name |
| :--- |
| Housekeeper execution time is High |

<BR>

## DASHBOARD

| Name |
| :--- |
| Housekeeper Stats |

<BR>

## DASHBOARD EXAMPLE

![Zabbix Housekeeper Dashboard](./image/dashboard_sample.png)

<BR>

| [⬆️ Top](#zabbix-housekeeper-stats-template) |
| --- |