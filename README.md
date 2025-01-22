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

- [Domain RDAP template](./monitor/rdap/)
- [Link Quality template](./monitor/link_quality/)
- [Windows Files Discovery template](./monitor/dir_list/)
- [Zabbix Housekeeper template](./monitor/housekeeper/)
- [Zabbix Slow Query template](./housekeeper/)
- [Zabbix WTTR.in template](./monitor/wttr/)

<BR>

### Codes

- [JavaScript Preprocessing](./javascript_preprocessing/)
    - [JavaScript Add Property](./javascript_preprocessing/javascript_add_property.md)
    - [JavaScript Remove Property](./javascript_preprocessing/javascript_remove_property.md)

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
