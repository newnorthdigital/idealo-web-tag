# Idealo Conversion Tracking - GTM Web Tag Template

A Google Tag Manager web tag template for tracking conversions from [idealo](https://idealo.de), one of Europe's largest price comparison platforms. This tag fires a 1x1 image pixel to idealo's tracking endpoint on your order confirmation page, allowing idealo to attribute sales back to clicks from their platform.

## Features

- Fires the official idealo conversion tracking pixel (`marketing.net.idealo-partner.com`)
- Sends order details: order ID, order value, and currency
- Supports item-level basket data (SKU, product name, brand, price, quantity)
- Optionally passes the idealo click ID (`idealoid`) for click-level attribution
- Debug logging mode for troubleshooting
- No external scripts loaded -- uses a lightweight image pixel only

## Installation

### From the Community Template Gallery

1. In your GTM container, go to **Templates** > **Tag Templates** > **Search Gallery**
2. Search for **Idealo Conversion Tracking**
3. Click **Add to workspace**

### Manual Installation

1. Download `template.tpl` from this repository
2. In GTM, go to **Templates** > **Tag Templates** > **New**
3. Click the three-dot menu > **Import**
4. Select the downloaded `template.tpl` file

## Setup Guide

### 1. Get your Partner Code

Your idealo partner code is provided by idealo when you set up your merchant account. It typically looks like `i5677845`. You can find it in your idealo merchant portal or in the tracking snippet idealo provides.

### 2. Create the Tag

1. Go to **Tags** > **New**
2. Choose **Idealo Conversion Tracking** as the tag type
3. Fill in the fields:

| Field | Description | Example |
|-------|-------------|---------|
| **Partner Code** | Your idealo partner code | `i5677845` |
| **Order ID** | Unique order identifier (use a GTM variable) | `{{Order ID}}` |
| **Order Value** | Total order value including taxes | `{{Order Total}}` |
| **Currency** | ISO 4217 currency code (defaults to EUR) | `EUR` |
| **Basket Items** | Optional product-level data (see below) | -- |
| **Idealo Click ID** | Optional click ID from the `idealoid` URL parameter | `{{idealo Click ID}}` |
| **Enable debug logging** | Logs details to the browser console | Disable in production |

### 3. Basket Items

To send item-level data, add rows to the Basket Items table. Each row represents one product:

| Column | Description | Example |
|--------|-------------|---------|
| Product ID / SKU | Product identifier | `SKU-12345` |
| Product Name | Name of the product | `Running Shoes Pro` |
| Brand | Product brand or manufacturer | `Nike` |
| Unit Price | Price per unit (decimal) | `89.95` |
| Quantity | Number of units purchased | `1` |

For dynamic basket data, use a Custom JavaScript variable or dataLayer variable that returns an array of objects with `pid`, `prn`, `brn`, `pri`, and `qty` keys.

### 4. Capturing the Idealo Click ID

When a user clicks through from idealo to your shop, idealo appends an `idealoid` parameter to the URL. To capture this:

1. Create a **URL Variable** in GTM:
   - Variable type: URL
   - Component type: Query
   - Query Key: `idealoid`
2. Optionally store it in a first-party cookie so it persists across pages
3. Pass it to the tag via the **Idealo Click ID** field

### 5. Set the Trigger

Fire this tag on your order confirmation / thank-you page. Use a Page View or custom event trigger that matches your order confirmation page URL.

## Permissions

This template requires the following GTM sandbox permissions:

| Permission | Scope | Purpose |
|------------|-------|---------|
| `send_pixel` | `https://marketing.net.idealo-partner.com/*` | Fires the conversion tracking pixel |
| `logging` | `debug` environment only | Console logging when debug mode is enabled |

## How It Works

The tag constructs a URL to idealo's tracking endpoint:

```
https://marketing.net.idealo-partner.com/ts/{partnerCode}/tsa?typ=i&tst={timestamp}&trc=basket&ctg=sale&sid=checkout&cid={orderId}&orv={orderValue}&orc={currency}&bsk={basketJson}&cli={clickId}
```

It then fires this URL as an image pixel using GTM's `sendPixel` API. No external JavaScript is loaded.

## Resources

- [idealo Merchant Portal](https://partner.idealo.com)
- [idealo Business (DE)](https://www.idealo.de/business)
- [Magento 2 idealo Tracking Module](https://github.com/mediarox/module-idealo-tracking-pixel) (reference implementation)

## Author

Built and maintained by [New North Digital](https://newnorth.digital?utm_source=github&utm_medium=gtm-template&utm_campaign=idealo-web-tag).

## License

Apache License 2.0 -- see [LICENSE](LICENSE).
