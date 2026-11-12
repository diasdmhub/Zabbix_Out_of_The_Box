| [↩️ Back](../) |
| --- |

# Public IP Address Zabbix Template by HTTP

<div align="right">

[![License](https://img.shields.io/badge/License-GPL3-blue?logo=opensourceinitiative&logoColor=fff)][license]
[![Version](https://img.shields.io/badge/Version-800-blue?logo=zotero&color=0aa8d2)][template_file]

</div>

<BR>

## OVERVIEW

Internet links with dynamic addressing may have their public IP address changed by the ISP at any time. This affects services that depend on it, such as DNS records, VPN peers, firewall allowlists and remote access. A gateway can report its WAN address, but behind a CGNAT, a modem in router mode or a provider-side NAT, that address is not necessarily the one the Internet sees.

This template collects the public IPv4 and IPv6 addresses from an **external perspective**, by querying a public provider that returns the origin address of the request. It alerts when an address changes and when an address can no longer be collected.

By default, the template uses the Cloudflare [`/cdn-cgi/trace`][cf_trace] endpoint. The request URLs use the Cloudflare IPv4 and IPv6 address literals (`1.1.1.1` and `[2606:4700:4700::1111]`) instead of a domain name. Therefore, there is no DNS lookup, and each request is forced to use the correct address family. This solves a common issue with dual-stack providers. For instance, a domain name with both `A` and `AAAA` records may be reached over IPv6, even when the item is expected to return the IPv4 address.

<BR>

## REQUIREMENTS

- The Zabbix Server or Proxy that monitors the host must have Internet access through the link being checked.
    - The items run on the Zabbix Server or Proxy, so the collected addresses are the ones used by **its** outbound traffic.
- The IPv6 item requires a working IPv6 route on the Zabbix Server or Proxy.
- If domain names are used for the provider macros, the Zabbix Server or Proxy must be able to resolve them.

> **No host interface is required. The template can be linked to a host that only represents the Internet link.**

<BR>

---
### ➡️ [Download][template_file]
---
#### ➡️ [_How to import templates_][import_templates]
---

<BR>

## HOW IT WORKS

1. Each item builds its URL from the provider macros: `{$INT.PROVIDER.SCHEMA}://{$INT.PROVIDER.IPV4}{$INT.PROVIDER.ENDPOINT}` for IPv4, and `{$INT.PROVIDER.SCHEMA}://{$INT.PROVIDER.IPV6}{$INT.PROVIDER.ENDPOINT}` for IPv6.
2. The provider returns the origin address of the request. Cloudflare returns a `key=value` text, where the address is in the `ip=` line.
3. A regular expression preprocessing step, taken from the `{$INT.PROVIDER.REGEX}` macro, extracts the address from the raw response.
4. A validation step checks if the extracted value looks like an IPv4 or IPv6 address. Otherwise, the item becomes unsupported with an `Invalid IPv4/6 address`, and no false value is stored.
5. Unchanged values are discarded, with a heartbeat of `1d`. Therefore, a healthy item stores at least one value a day, and a new value is stored as soon as the address changes.

<BR>

## ALTERNATIVE PROVIDERS

The provider is meant to be changed with **host-level macros**. The table below lists some providers that were tested with this template.

| Provider   | `{$INT.PROVIDER.IPV4}` | `{$INT.PROVIDER.IPV6}`     | `{$INT.PROVIDER.ENDPOINT}` | `{$INT.PROVIDER.REGEX}` |
| ---------- | ---------------------- | -------------------------- | -------------------------- | ----------------------- |
| Cloudflare | `1.1.1.1`              | `[2606:4700:4700::1111]`   | `/cdn-cgi/trace`           | `(?m)^ip=(\S+)$`        |
| ipify      | `api.ipify.org`        | `api6.ipify.org`           | `/`                        | `^(\S+)`                |
| icanhazip  | `ipv4.icanhazip.com`   | `ipv6.icanhazip.com`       | `/`                        | `^(\S+)`                |
| GeoJS      | `ipv4.geojs.io`        | N/A                        | `/v1/ip/geo.json`          | `"ip":"([^"]+)"`        |

> ⚠️ **When changing the provider, consider that:**
> - **A domain name used for the IPv4 macro must have only an `A` record, and a domain name used for the IPv6 macro must have only an `AAAA` record. Otherwise, the request may use the wrong address family. Use the provider's single-stack hostnames, or IP literals.**
> - **The endpoint and regex macros are shared by both items. Therefore, IPv4 and IPv6 must use the same provider, or providers with the same endpoint and response format.**
> - **The regex macro must have one capture group, because the preprocessing step returns `\1`.**
> - **SSL peer and host verification are enabled. When an IP literal is used with `https`, the provider's certificate must include that IP address.**
> - **If a provider has no IPv6 endpoint, such as GeoJS, disable the IPv6 item on the host.**

<BR>

## REMARKS

- The items are updated once an hour. This is a conservative period to minimize the requests sent to the provider. Public providers may limit or block abusive clients.
- The IPv6 address is the address of the Zabbix Server or Proxy itself, not a site-wide address. Unlike a NAT IPv4 address, it may change when the host interface address changes, for example with SLAAC privacy addresses.
- If the host has no IPv6 connectivity, the IPv6 item becomes unsupported, and the `Public Address Unavailable IPv6` trigger fires after 25 hours. In this case, disable the IPv6 item on the host.
- The `nodata()` triggers should ignore missing data while the host's Zabbix Proxy is unavailable.

<BR>

---

<BR>

## 🔶 Template `Public IP Address by HTTP`

### MACROS

| Macro                      | Default Value            | Description |
| -------------------------- | :----------------------: | ----------- |
| `{$INT.PROVIDER.ENDPOINT}` | `/cdn-cgi/trace`         | Provider URL endpoint for the request |
| `{$INT.PROVIDER.IPV4}`     | `1.1.1.1`                | Provider URL IPv4 address or domain name for the request |
| `{$INT.PROVIDER.IPV6}`     | `[2606:4700:4700::1111]` | Provider URL IPv6 address or domain name for the request. Use brackets for IPv6 literals |
| `{$INT.PROVIDER.REGEX}`    | `(?m)^ip=(\S+)$`         | Regular expression to extract IP information from the provider raw response. **Must have one capture group** |
| `{$INT.PROVIDER.SCHEMA}`   | `https`                  | Provider `http` or `https` URL schema |

<BR>

### ITEMS

| Name                | Description |
| ------------------- | ----------- |
| Public Address IPv4 | IPv4 address checked from an external provider endpoint |
| Public Address IPv6 | IPv6 address checked from an external provider endpoint |

<BR>

### TRIGGERS

| Name                            | Description |
| ------------------------------- | ----------- |
| Public Address Changed IPv4     | The IPv4 public address was changed recently. |
| Public Address Changed IPv6     | The IPv6 public address was changed recently. |
| Public Address Unavailable IPv4 | No IPv4 public address was collected in the last 25 hours. |
| Public Address Unavailable IPv6 | No IPv6 public address was collected in the last 25 hours. |

<BR>

| [⬆️ Top](#public-ip-address-zabbix-template-by-http) |
| --- |

[cf_trace]: https://developers.cloudflare.com/fundamentals/reference/cdn-cgi-endpoint/
[template_file]: ./public_ip_address.yaml
[import_templates]: https://www.zabbix.com/documentation/current/en/manual/config/xml_export_import/templates#importing
[license]: ./../../LICENSE
