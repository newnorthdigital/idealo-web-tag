___TERMS_OF_SERVICE___

By creating or modifying this file you agree to Google Tag Manager's Community
Template Gallery Developer Terms of Service available at
https://developers.google.com/tag-manager/gallery-tos (or such other URL as
Google may provide), as modified from time to time.


___INFO___

{
  "type": "TAG",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "Idealo Conversion Tracking",
  "categories": [
    "CONVERSIONS",
    "ADVERTISING"
  ],
  "brand": {
    "id": "brand_dummy",
    "displayName": "New North Digital",
    "thumbnail": ""
  },
  "description": "Tracks conversions for idealo price comparison. Fires a 1x1 image pixel to marketing.net.idealo-partner.com with order details including basket items, value, and currency.",
  "containerContexts": [
    "WEB"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "TEXT",
    "name": "partner_code",
    "displayName": "Partner Code",
    "simpleValueType": true,
    "alwaysInSummary": true,
    "help": "Your idealo partner code (e.g. i5677845). You can find this in your idealo merchant account or in the tracking snippet provided by idealo.",
    "valueValidators": [
      {
        "type": "NON_EMPTY"
      }
    ]
  },
  {
    "type": "TEXT",
    "name": "order_id",
    "displayName": "Order ID",
    "simpleValueType": true,
    "alwaysInSummary": true,
    "help": "The unique order or conversion ID. Typically populated from a GTM variable referencing the order confirmation data.",
    "valueValidators": [
      {
        "type": "NON_EMPTY"
      }
    ]
  },
  {
    "type": "TEXT",
    "name": "order_value",
    "displayName": "Order Value",
    "simpleValueType": true,
    "alwaysInSummary": true,
    "help": "The total order value including taxes. Use a decimal number (e.g. 49.95).",
    "valueValidators": [
      {
        "type": "NON_EMPTY"
      }
    ]
  },
  {
    "type": "TEXT",
    "name": "currency",
    "displayName": "Currency",
    "simpleValueType": true,
    "defaultValue": "EUR",
    "help": "ISO 4217 currency code (e.g. EUR, GBP, CHF).",
    "valueValidators": [
      {
        "type": "NON_EMPTY"
      }
    ]
  },
  {
    "type": "SIMPLE_TABLE",
    "name": "basket_items",
    "displayName": "Basket Items",
    "simpleTableColumns": [
      {
        "defaultValue": "",
        "displayName": "Product ID / SKU",
        "name": "pid",
        "type": "TEXT"
      },
      {
        "defaultValue": "",
        "displayName": "Product Name",
        "name": "prn",
        "type": "TEXT"
      },
      {
        "defaultValue": "",
        "displayName": "Brand",
        "name": "brn",
        "type": "TEXT"
      },
      {
        "defaultValue": "",
        "displayName": "Unit Price",
        "name": "pri",
        "type": "TEXT"
      },
      {
        "defaultValue": "",
        "displayName": "Quantity",
        "name": "qty",
        "type": "TEXT"
      }
    ],
    "help": "Add items from the order basket. Each row represents one product in the order. Leave empty if you do not want to send item-level data."
  },
  {
    "type": "TEXT",
    "name": "idealo_click_id",
    "displayName": "Idealo Click ID (optional)",
    "simpleValueType": true,
    "help": "The idealo click ID from the idealoid URL parameter. If provided, it will be sent as the cli parameter. Use a GTM variable that reads the idealoid query parameter or a first-party cookie storing it."
  },
  {
    "type": "CHECKBOX",
    "name": "debug",
    "displayName": "Enable debug logging",
    "simpleValueType": true,
    "defaultValue": false,
    "help": "When enabled, logs debug information to the browser console. Disable in production."
  }
]


___SANDBOXED_JS_FOR_WEB_TEMPLATE___

var log = require('logToConsole');
var sendPixel = require('sendPixel');
var encodeUriComponent = require('encodeUriComponent');
var getTimestampMillis = require('getTimestampMillis');
var makeString = require('makeString');
var makeNumber = require('makeNumber');
var Math = require('Math');
var JSON = require('JSON');
var getType = require('getType');

var enableDebug = data.debug;
var debugLog = function(msg) {
  if (enableDebug) log('Idealo GTM - ' + msg);
};

var partnerCode = makeString(data.partner_code);
var orderId = makeString(data.order_id);
var orderValue = makeString(data.order_value);
var currency = makeString(data.currency || 'EUR');
var timestamp = makeString(Math.round(getTimestampMillis() / 1000));

debugLog('Partner code: ' + partnerCode);
debugLog('Order ID: ' + orderId);
debugLog('Order value: ' + orderValue + ' ' + currency);

// Build basket JSON array
var basketJson = '';
if (getType(data.basket_items) === 'array' && data.basket_items.length > 0) {
  var items = [];
  for (var i = 0; i < data.basket_items.length; i++) {
    var item = data.basket_items[i];
    var obj = {};
    if (item.pid) obj.pid = makeString(item.pid);
    if (item.prn) obj.prn = makeString(item.prn);
    if (item.brn) obj.brn = makeString(item.brn);
    if (item.pri) obj.pri = makeString(item.pri);
    if (item.qty) obj.qty = makeString(makeNumber(item.qty));
    items.push(obj);
  }
  basketJson = JSON.stringify(items);
  debugLog('Basket items: ' + basketJson);
}

// Build pixel URL
var baseUrl = 'https://marketing.net.idealo-partner.com/ts/' +
  encodeUriComponent(partnerCode) + '/tsa';

var params = '?typ=i' +
  '&tst=' + encodeUriComponent(timestamp) +
  '&trc=basket' +
  '&ctg=sale' +
  '&sid=checkout' +
  '&cid=' + encodeUriComponent(orderId) +
  '&orv=' + encodeUriComponent(orderValue) +
  '&orc=' + encodeUriComponent(currency);

if (basketJson) {
  params = params + '&bsk=' + encodeUriComponent(basketJson);
}

if (data.idealo_click_id) {
  params = params + '&cli=' + encodeUriComponent(makeString(data.idealo_click_id));
  debugLog('Click ID: ' + makeString(data.idealo_click_id));
}

var pixelUrl = baseUrl + params;
debugLog('Pixel URL: ' + pixelUrl);

sendPixel(pixelUrl, function() {
  debugLog('Pixel sent successfully');
  data.gtmOnSuccess();
}, function() {
  debugLog('Pixel failed to send');
  data.gtmOnFailure();
});


___WEB_PERMISSIONS___

[
  {
    "instance": {
      "key": {
        "publicId": "send_pixel",
        "vpiVersion": "2"
      },
      "param": [
        {
          "key": "allowedUrls",
          "value": {
            "type": 1,
            "string": "specific"
          }
        },
        {
          "key": "urls",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 1,
                "string": "https://marketing.net.idealo-partner.com/*"
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "logging",
        "vpiVersion": "1"
      },
      "param": [
        {
          "key": "environments",
          "value": {
            "type": 1,
            "string": "debug"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  }
]


___TESTS___

scenarios:
- name: "Fires pixel with required fields only"
  code: |-
    var mockData = {
      partner_code: 'i5677845',
      order_id: 'ORD-12345',
      order_value: '149.95',
      currency: 'EUR',
      debug: false
    };

    mock('sendPixel', function(url, onSuccess, onFailure) {
      onSuccess();
    });

    runCode(mockData);

    assertApi('sendPixel').wasCalled();
    assertApi('gtmOnSuccess').wasCalled();
- name: "Fires pixel with basket items and click ID"
  code: |-
    var mockData = {
      partner_code: 'i5677845',
      order_id: 'ORD-99887',
      order_value: '299.90',
      currency: 'EUR',
      basket_items: [
        { pid: 'SKU-001', prn: 'Widget A', brn: 'Acme', pri: '149.95', qty: '2' }
      ],
      idealo_click_id: 'abc123xyz',
      debug: true
    };

    mock('sendPixel', function(url, onSuccess, onFailure) {
      onSuccess();
    });

    runCode(mockData);

    assertApi('sendPixel').wasCalled();
    assertApi('gtmOnSuccess').wasCalled();
- name: "Calls gtmOnFailure when pixel send fails"
  code: |-
    var mockData = {
      partner_code: 'i5677845',
      order_id: 'ORD-FAIL',
      order_value: '50.00',
      currency: 'EUR',
      debug: false
    };

    mock('sendPixel', function(url, onSuccess, onFailure) {
      onFailure();
    });

    runCode(mockData);

    assertApi('sendPixel').wasCalled();
    assertApi('gtmOnFailure').wasCalled();
- name: "Defaults to EUR when currency is empty"
  code: |-
    var mockData = {
      partner_code: 'i1234567',
      order_id: 'ORD-EUR',
      order_value: '25.00',
      currency: '',
      debug: false
    };

    mock('sendPixel', function(url, onSuccess, onFailure) {
      onSuccess();
    });

    runCode(mockData);

    assertApi('sendPixel').wasCalled();
    assertApi('gtmOnSuccess').wasCalled();
- name: "Sends pixel without basket when basket items is empty"
  code: |-
    var mockData = {
      partner_code: 'i9999999',
      order_id: 'ORD-NOBSK',
      order_value: '10.00',
      currency: 'GBP',
      basket_items: [],
      debug: true
    };

    mock('sendPixel', function(url, onSuccess, onFailure) {
      onSuccess();
    });

    runCode(mockData);

    assertApi('sendPixel').wasCalled();
    assertApi('gtmOnSuccess').wasCalled();


___NOTES___

Created on 4/1/2026, by New North Digital BV.
Idealo conversion tracking pixel for price comparison attribution.
Pixel endpoint: https://marketing.net.idealo-partner.com/ts/{partnerCode}/tsa
