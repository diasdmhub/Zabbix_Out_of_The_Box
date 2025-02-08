# ZABBIX OUT OF THE BOX

Due to the many scenarios that are handled on a daily basis with Zabbix, it is easy to forget or simply misplace an intelligent solution to a monitoring scenario. Therefore, this repository has been created to store standard and different approaches to Zabbix monitoring.
It is also of interest to disclose limitations found as well as innovations as they may help future monitoring projects.

This could be referenced as a knowledge base (KB) for Zabbix scenarios, issues or general tips.

<BR>

## CONTENTS

### Install

- [Installation check-list](./install/install_list.md)
- [Zabbix Podman Pod](./pod/zabbix_pod.md)

<BR>

### Templates

- [AdGuard Home template](https://github.com/diasdmhub/AdGuard_Home_Zabbix_Template)
- [Asus WRT Merlin Routers](https://github.com/diasdmhub/Asus_Merlin_Zabbix_Template)
- [Domain RDAP template](./monitor/rdap/)
- [Link Quality template](./monitor/link_quality/)
- [NVR Intelbras / Dahua by SNMP template](https://github.com/diasdmhub/Intelbras_NVR_Zabbix_Template)
- [Windows Files Discovery template](./monitor/dir_list/)
- [WTTR.in template](./monitor/wttr/)
- [Zabbix Housekeeper template](./monitor/housekeeper/)
- [Zabbix Slow Query template](./monitor/slow_query/)

<BR>

### Codes

- [JavaScript](./javascript/)
    - [JavaScript Add Property](./javascript/javascript_add_property.md)
    - [JavaScript Remove Property](./javascript/javascript_remove_property.md)

<BR>

### Aggregation

- [Aggregations](./aggregation/)
    - [Count unique strings from items](./aggregation/count_unique_strings_items.md)

<BR>

### Event Correlation

- [Event Correlation](./correlation/)
    - [Overwritten Log File](./correlation/overwritten_log.md)

<BR>

### Issues

- [Regular Expression escaping](./issue/regex_escaping.md)
- [Analysis of Zabbix DNS Queries](./issue/zabbix_dns_query.md)
