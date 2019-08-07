# Run an SAP transaction with Postman

In this tutorial, we will use [Postman](https://www.getpostman.com/downloads/) to execute a complete SAP transaction without an SAP frontend.

## Overview

We will use the transaction **Post Goods Issue for Purchase Order** (`MIGO`) as our example. [Here](SAP_oData.md) we identified four API endpoints that are relevant for this transaction:

1. `/sap/opu/odata/sap/MMIM_GR4PO_DL_SRV/PoHelpSet` shows us open purchase orders.
2. `/sap/opu/odata/sap/MMIM_GR4PO_DL_SRV/GR4PO_DL_Headers` shows us a selected purchase order and opens an inbound delivery (a.k.a. goods receipt).
3. `/sap/opu/odata/sap/MMIM_MATERIAL_DATA_SRV/MaterialStorLocHelps` shows us appropriate storage locations.
4. Posting to `/sap/opu/odata/sap/MMIM_GR4PO_DL_SRV` allows us to record a goods receipt.

Let's replicate these steps using Postman.

## Prerequisites

You will need the following systems and tools to follow this tutorial:

1. An SAP S/4 HANA system. I use an instance provided by as SAP University Competence Center. These systems come preinstalled with a model company, which allows us to easily create purchase orders.
2. Make sure that the SAP Gateway is enabled. Use the transaction code `/n/iwfnd/gw_client` to open the gateway client. Request the URI `/sap/opu/odata/sap/MMIM_MATERIAL_DATA_SRV/$metadata`, this should give you a status code of 200 and status reason OK. If so, you are good to go. If not, check in with your SAP administrator.
2. A basic understanding of how to create and display purchase orders and how to record goods receipt.
2. Download or open [Postman](https://www.getpostman.com/downloads/). Postman allows you to build custom requests and issue API calls.  

## Process

1. We use Postman to check the list of existing purchase orders that are waiting for goods receipt.
1. We use the Web GUI of the SAP system to create a purchase order.
2. We use Postman again to check whether our created purchase order shows up.
3. We use Postman to open an inbound delivery (a.k.a. goods receipt).
4. We use Postman to get the available storage location.
5. We use Postman to post the inbound delivery.
6. We use the Web GUI of the SAP system to explore the completed purchase order.

Before we can jump into the process, we need to address cross-site request forgery. The SAP system provides a header element called `x-csrf-token` that allows us to fetch a token that allows us to communicate with the SAP system.

## Fetching the CSRF token

We need the CSRF (Cross-Site Request Forgery) to communicate with the SAP system.

In Postman, create a new GET request with the following parameters:

| Parameter | Value |
|-----------|---------|
| URL | http://sap.system.edu:port/sap/opu/odata/sap/MMIM_GR4PO_DL_SRV/?sap-client=XXX |
| Authorization | Type: `Basic` with username and password |
| Param `sap-client` | Key: `sap-client`, Value: `Your client id` |
| Header `x-csrf-token` | Key: `x-csrf-token`, Value: `Fetch` |

The minimal complete request looks like this (you can copy it to a terminal and execute it):
```
curl -X GET \
  'http://sap.system.edu:port/sap/opu/odata/sap/MMIM_GR4PO_DL_SRV/?sap-client=XXX' \
  -H 'Authorization: Basic ABCDEFGHIJKLMNOPQRSTUW==' \
  -H 'x-csrf-token: Fetch'
```
Please note that Postman will typically add header information. Please also note that the `Authorization` header contains the encoded authorization information.

Once executed, explore the response you have received. The body should consists of an XML document that explains the API endpoints for `MMIM_GR4PO_DL_SRV`:

```
<?xml version="1.0" encoding="utf-8"?>
<app:service xml:lang="en" xml:base="http://sap.system.edu:port/sap/opu/odata/sap/MMIM_GR4PO_DL_SRV/" xmlns:app="http://www.w3.org/2007/app" xmlns:atom="http://www.w3.org/2005/Atom" xmlns:m="http://schemas.microsoft.com/ado/2007/08/dataservices/metadata" xmlns:sap="http://www.sap.com/Protocols/SAPData">
    <app:workspace>
        <atom:title type="text">Data</atom:title>
        <app:collection sap:deletable="false" sap:pageable="false" sap:content-version="1" href="GR4PO_DL_Headers">
            <atom:title type="text">GR4PO_DL_Headers</atom:title>
            <sap:member-title>GR4PO_DL_Header</sap:member-title>
        </app:collection>
        <app:collection sap:deletable="false" sap:pageable="false" sap:content-version="1" href="GR4PO_DL_Items">
            <atom:title type="text">GR4PO_DL_Items</atom:title>
            <sap:member-title>GR4PO_DL_Item</sap:member-title>
        </app:collection>
        <app:collection sap:creatable="false" sap:updatable="false" sap:deletable="false" sap:pageable="false" sap:content-version="1" href="PoHelpSet">
            <atom:title type="text">PoHelpSet</atom:title>
            <sap:member-title>PoHelp</sap:member-title>
        </app:collection>
        <app:collection sap:creatable="false" sap:updatable="false" sap:deletable="false" sap:pageable="false" sap:content-version="1" href="MaterialBatchHelps">
            <atom:title type="text">MaterialBatchHelps</atom:title>
            <sap:member-title>MaterialBatchHelp</sap:member-title>
        </app:collection>
        <app:collection sap:creatable="false" sap:updatable="false" sap:deletable="false" sap:pageable="false" sap:content-version="1" href="InbDelHelpSet">
            <atom:title type="text">InbDelHelpSet</atom:title>
            <sap:member-title>InbDelHelp</sap:member-title>
        </app:collection>
        <app:collection sap:creatable="false" sap:updatable="false" sap:deletable="false" sap:pageable="false" sap:content-version="1" href="GoodsMovementReasons">
            <atom:title type="text">GoodsMovementReasons</atom:title>
            <sap:member-title>GoodsMovementReason</sap:member-title>
        </app:collection>
        <app:collection sap:creatable="false" sap:updatable="false" sap:deletable="false" sap:pageable="false" sap:content-version="1" href="StockTypeIndicators">
            <atom:title type="text">StockTypeIndicators</atom:title>
            <sap:member-title>StockTypeIndicator</sap:member-title>
        </app:collection>
    </app:workspace>
    <atom:link rel="self" href="http://sap.system.edu:port/sap/opu/odata/sap/MMIM_GR4PO_DL_SRV/"/>
    <atom:link rel="latest-version" href="http://sap.system.edu:port/sap/opu/odata/sap/MMIM_GR4PO_DL_SRV/"/>
</app:service>
```

Furthermore, check the response headers. There should be quite a few but among them you should find the header `x-csrf-token` with a value of the format `abcdefghijklmnopqustuw==`. Copy the token to a work document. You will need at later.

### Use Postman to check the list of existing purchase orders that are waiting for goods receipt

In Postman, create a new GET request with the following parameters:

| Parameter | Value |
|-----------|---------|
| URL | http://sap.system.edu:port/sap/opu/odata/sap/MMIM_GR4PO_DL_SRV/PoHelpSet?sap-client=XXX |
| Authorization | Type: `Basic` with username and password |
| Param `sap-client` | Key: `sap-client`, Value: `Your client id` |
| Header `x-csrf-token` | Key: `x-csrf-token`, Value: `Your token` |

The minimal complete request looks like this (you can copy it to a terminal and execute it):

```
curl -X GET \
  'http://sap.system.edu:port/sap/opu/odata/sap/MMIM_GR4PO_DL_SRV/PoHelpSet?sap-client=140' \
  -H 'Authorization: Basic ABCDEFGHIJKLMNOPQRSTUW==' \
  -H 'x-csrf-token: abcdefghijklmnopqustuw=='
```

The response should be an XML document.

```
<feed xmlns="http://www.w3.org/2005/Atom" xmlns:m="http://schemas.microsoft.com/ado/2007/08/dataservices/metadata" xmlns:d="http://schemas.microsoft.com/ado/2007/08/dataservices" xml:base="http://sap.system.edu:port/sap/opu/odata/sap/MMIM_GR4PO_DL_SRV/">
    <id>http://sap.system.edu:port/sap/opu/odata/sap/MMIM_GR4PO_DL_SRV/PoHelpSet</id>
    <title type="text">PoHelpSet</title>
    <updated>2019-08-06T21:07:56Z</updated>
    <author>
        <name/>
    </author>
    <link href="PoHelpSet" rel="self" title="PoHelpSet"/>
    <m:count>41</m:count>
    <entry>
        <id>http://sap.system.edu:port/sap/opu/odata/sap/MMIM_GR4PO_DL_SRV/PoHelpSet(PurchaseOrder='4500000041',PurchaseOrderItem='00010')</id>
        <title type="text">PoHelpSet(PurchaseOrder='4500000041',PurchaseOrderItem='00010')</title>
        <updated>2019-08-06T21:07:56Z</updated>
        <category term="MMIM_GR4PO_DL_SRV.PoHelp" scheme="http://schemas.microsoft.com/ado/2007/08/dataservices/scheme"/>
        <link href="PoHelpSet(PurchaseOrder='4500000041',PurchaseOrderItem='00010')" rel="self" title="PoHelp"/>
        <content type="application/xml">
            <m:properties xmlns:m="http://schemas.microsoft.com/ado/2007/08/dataservices/metadata" xmlns:d="http://schemas.microsoft.com/ado/2007/08/dataservices">
                <d:PurchaseOrder>4500000041</d:PurchaseOrder>
                <d:PurchaseOrderItem>00010</d:PurchaseOrderItem>
                <d:Supplier></d:Supplier>
                <d:SupplierName></d:SupplierName>
                <d:SupplierCityName></d:SupplierCityName>
                <d:SupplyingPlant></d:SupplyingPlant>
                <d:SupplyingPlantName></d:SupplyingPlantName>
                <d:Material>ORTR1105</d:Material>
                <d:PurchaseOrderItemText>Off Road Tires</d:PurchaseOrderItemText>
                <d:PurchasingDocumentType>NB</d:PurchasingDocumentType>
                <d:PurchasingDocumentTypeName>Standard PO</d:PurchasingDocumentTypeName>
                <d:PurOrdPurchasingOrganization>US00</d:PurOrdPurchasingOrganization>
                <d:PurOrdPurchasingGroup>N00</d:PurOrdPurchasingGroup>
                <d:Plant>DL00</d:Plant>
            </m:properties>
        </content>
    </entry>
    ...
</feed>
```

Please note that, in this example system, we have 41 open purchase orders.

### Use the Web GUI of the SAP system to create a purchase order

Next, we create a new purchase order in the system. You can use any graphical user interface; in this example, we use the Web GUI.

**First**, use the transaction code `ME21N` to create an empty purchase order document.

![ME21N](img/me21n.png)

**Second**, complete the purchase order by filling in the header information. Here, I use the organizational and vendor information of the SAP UCC model company.

![PO Header](img/create_po.png)

**Third**, complete the item information. Choose a product, a quantity, and a storage facility. Again, I use information from the SAP UCC model company.

![PO Items](img/po_item.png)

**Fourth**, manage any warnings and save the purchase order. You should get the purchase order number as part of a confirmation message.

![PO Success](img/create_po_success.png)

This should have created a new purchase order. Let's check the system again to confirm.

### Use Postman to check for the newly created purchase order

Rerun the request from above again.

| Parameter | Value |
|-----------|---------|
| URL | http://sap.system.edu:port/sap/opu/odata/sap/MMIM_GR4PO_DL_SRV/PoHelpSet?sap-client=XXX |
| Authorization | Type: `Basic` with username and password |
| Param `sap-client` | Key: `sap-client`, Value: `Your client id` |
| Header `x-csrf-token` | Key: `x-csrf-token`, Value: `Your token` |

The minimal complete request looks like this (you can copy it to a terminal and execute it):

```
curl -X GET \
  'http://sap.system.edu:port/sap/opu/odata/sap/MMIM_GR4PO_DL_SRV/PoHelpSet?sap-client=140' \
  -H 'Authorization: Basic ABCDEFGHIJKLMNOPQRSTUW==' \
  -H 'x-csrf-token: abcdefghijklmnopqustuw=='
```

If the CSRF token has expired in the meantime, you need to fetch a new token. Check the response. You should see the following update.

```
...
<m:count>42</m:count>
...
```

It looks like our new purchase order is in the system.

### Use Postman to open an inbound delivery (a.k.a. goods receipt)

Set up a `GET` request with the following parameters.

| Parameter | Value |
|-----------|---------|
| URL | http://sap.system.edu:port/sap/opu/odata/sap/MMIM_GR4PO_DL_SRV/GR4PO_DL_Headers?sap-client=XXX |
| Authorization | Type: `Basic` with username and password |
| Param `sap-client` | Key: `sap-client`, Value: `Your client id` |
| Header `x-csrf-token` | Key: `x-csrf-token`, Value: `Your token` |
| Param `$expand` | Key `$expand`, Value: `Header2Items%2CHeader2Items%2FItem2StockTypes` |
| Param `$filter` | Key `$filter`, Value: `SourceOfGR%20eq%20%27PURORD%27%20and%20InboundDelivery%20eq%20%27{0123456789}%27`, Replace `{0123456789}` with your purchase order number |

The minimal complete request looks like this:

```
curl -X GET \
  'http://sap.system.edu:port/sap/opu/odata/sap/MMIM_GR4PO_DL_SRV/GR4PO_DL_Headers?sap-client=XXX&$expand=Header2Items%2CHeader2Items%2FItem2StockTypes&$filter=SourceOfGR%20eq%20%27PURORD%27%20and%20InboundDelivery%20eq%20%27{0123456789}%27' \
  -H 'Authorization: Basic ABCDEFGHIJKLMNOPQRSTUW==' \
  -H 'x-csrf-token: abcdefghijklmnopqustuw=='
```

The response should look like this (Please note that this is an abbreviated version).

```
<feed xmlns="http://www.w3.org/2005/Atom" xmlns:m="http://schemas.microsoft.com/ado/2007/08/dataservices/metadata" xmlns:d="http://schemas.microsoft.com/ado/2007/08/dataservices" xml:base="http://sap.system.edu:port/sap/opu/odata/sap/MMIM_GR4PO_DL_SRV/">
    <id>http://sap.system.edu:port/sap/opu/odata/sap/MMIM_GR4PO_DL_SRV/GR4PO_DL_Headers</id>
    <title type="text">GR4PO_DL_Headers</title>
    <updated>2019-08-06T21:34:27Z</updated>
    <author>
        <name/>
    </author>
    <link href="GR4PO_DL_Headers" rel="self" title="GR4PO_DL_Headers"/>
    <entry>
        <id>http://sap.system.edu:port/sap/opu/odata/sap/MMIM_GR4PO_DL_SRV/GR4PO_DL_Headers(InboundDelivery='4500000017',SourceOfGR='PURORD')</id>
        <title type="text">GR4PO_DL_Headers(InboundDelivery='4500000017',SourceOfGR='PURORD')</title>
        <updated>2019-08-06T21:34:27Z</updated>
        <category term="MMIM_GR4PO_DL_SRV.GR4PO_DL_Header" scheme="http://schemas.microsoft.com/ado/2007/08/dataservices/scheme"/>
        <link href="GR4PO_DL_Headers(InboundDelivery='4500000017',SourceOfGR='PURORD')" rel="edit" title="GR4PO_DL_Header"/>
        <link href="GR4PO_DL_Headers(InboundDelivery='4500000017',SourceOfGR='PURORD')/Header2Items" rel="http://schemas.microsoft.com/ado/2007/08/dataservices/related/Header2Items" type="application/atom+xml;type=feed" title="Header2Items">
            <m:inline>
            ...
        <content type="application/xml">
            <m:properties xmlns:m="http://schemas.microsoft.com/ado/2007/08/dataservices/metadata" xmlns:d="http://schemas.microsoft.com/ado/2007/08/dataservices">
                <d:InboundDelivery>4500000017</d:InboundDelivery>
                <d:SourceOfGR>PURORD</d:SourceOfGR>
                <d:PurchasingDocumentType>NB</d:PurchasingDocumentType>
                <d:PurchasingDocumentTypeName>Standard PO</d:PurchasingDocumentTypeName>
                <d:DocumentDate>2019-08-06T00:00:00</d:DocumentDate>
                <d:PostingDate>2019-08-06T00:00:00</d:PostingDate>
                <d:DeliveryDocumentByVendor></d:DeliveryDocumentByVendor>
                <d:BillOfLading></d:BillOfLading>
                <d:Vendor>101013</d:Vendor>
                <d:VendorName>Olympic Protective Gear</d:VendorName>
                <d:SupplyingPlant></d:SupplyingPlant>
                <d:SupplyingPlantName></d:SupplyingPlantName>
                <d:MaterialDocumentHeaderText></d:MaterialDocumentHeaderText>
                <d:Temp_Key></d:Temp_Key>
                <d:VersionForPrintingSlip></d:VersionForPrintingSlip>
            </m:properties>
        </content>
    </entry>
</feed>
```

Next, we need to identify where we can put the ordered materials.

### Use Postman to get the available storage location

Set up a `GET` request with the following parameters.

| Parameter | Value |
|-----------|---------|
| URL | http://sap.system.edu:port/sap/opu/odata/sap/MMIM_MATERIAL_DATA_SRV/MaterialStorLocHelps?sap-client=XXX |
| Authorization | Type: `Basic` with username and password |
| Param `sap-client` | Key: `sap-client`, Value: `Your client id` |
| Header `x-csrf-token` | Key: `x-csrf-token`, Value: `Your token` |
| Param `$filter` | Key `$filter`, Value: `$filter=Material%20eq%20%27{ORDERED_MATERIAL}%27%20and%20Plant%20eq%20%27{STORAGE_FACILITY}%27`, Replace `{ORDERED_MATERIAL}` with the material in the purchase order and {STORAGE_FACILITY} with the designated storage facility |

The minimal complete request looks like this:

```
curl -X GET \
  'http://sap.system.edu:port/sap/opu/odata/sap/MMIM_MATERIAL_DATA_SRV/MaterialStorLocHelps?sap-client=XXX&$filter=Material%20eq%20%27{ORDERED_MATERIAL}%27%20and%20Plant%20eq%20%27{STORAGE_FACILITY}%27' \
  -H 'Authorization: Basic ABCDEFGHIJKLMNOPQRSTUW==' \
  -H 'x-csrf-token: abcdefghijklmnopqustuw=='
```

The response should look like this.

```
<feed xmlns="http://www.w3.org/2005/Atom" xmlns:m="http://schemas.microsoft.com/ado/2007/08/dataservices/metadata" xmlns:d="http://schemas.microsoft.com/ado/2007/08/dataservices" xml:base="http://sap.system.edu:port/sap/opu/odata/sap/MMIM_MATERIAL_DATA_SRV/">
    <id>http://sap.system.edu:port/sap/opu/odata/sap/MMIM_MATERIAL_DATA_SRV/MaterialStorLocHelps</id>
    <title type="text">MaterialStorLocHelps</title>
    <updated>2019-08-07T03:13:31Z</updated>
    <author>
        <name/>
    </author>
    <link href="MaterialStorLocHelps" rel="self" title="MaterialStorLocHelps"/>
    ...
    <entry>
        <id>http://sap.system.edu:port/sap/opu/odata/sap/MMIM_MATERIAL_DATA_SRV/MaterialStorLocHelps(Material='OHMT1013',Plant='MI00',StorageLocation='TG00')</id>
        <title type="text">MaterialStorLocHelps(Material='OHMT1013',Plant='MI00',StorageLocation='TG00')</title>
        <updated>2019-08-07T03:13:31Z</updated>
        <category term="MMIM_MATERIAL_DATA_SRV.MaterialStorLocHelp" scheme="http://schemas.microsoft.com/ado/2007/08/dataservices/scheme"/>
        <link href="MaterialStorLocHelps(Material='OHMT1013',Plant='MI00',StorageLocation='TG00')" rel="self" title="MaterialStorLocHelp"/>
        <content type="application/xml">
            <m:properties xmlns:m="http://schemas.microsoft.com/ado/2007/08/dataservices/metadata" xmlns:d="http://schemas.microsoft.com/ado/2007/08/dataservices">
                <d:Material>OHMT1013</d:Material>
                <d:Plant>MI00</d:Plant>
                <d:StorageLocation>TG00</d:StorageLocation>
                <d:StorageLocationName>Trading Goods</d:StorageLocationName>
                <d:CalendarDate>2019-08-06T00:00:00</d:CalendarDate>
                <d:CurrentStock>20.000</d:CurrentStock>
                <d:QualityInspectionStockQuantity>0.000</d:QualityInspectionStockQuantity>
                <d:ReturnsBlockedStockQuantity>0.000</d:ReturnsBlockedStockQuantity>
                <d:TransferStockStorageLocQty>0.000</d:TransferStockStorageLocQty>
                <d:BlockedStockQuantity>0.000</d:BlockedStockQuantity>
                <d:RestrictedStockQuantity>0.000</d:RestrictedStockQuantity>
                <d:BaseUnit>EA</d:BaseUnit>
            </m:properties>
        </content>
    </entry>
</feed>
```

This is an example for a storage location `TG00` for trading goods in the storage facility `MI00`.

### Use Postman to post the inbound delivery.

Set up a `POST` request with the following parameters.

| Parameter | Value |
|-----------|---------|
| URL | http://sap.system.edu:port/sap/opu/odata/sap/MMIM_GR4PO_DL_SRV/GR4PO_DL_Headers?sap-client=XXX |
| Authorization | Type: `Basic` with username and password |
| Param `sap-client` | Key: `sap-client`, Value: `Your client id` |
| Header `x-csrf-token` | Key: `x-csrf-token`, Value: `Your token` |
| Param `Content-Type` | Key `Content-Type`, Value: `application/json` |

The body of the request needs to include the following payload.

```
{
  "InboundDelivery": "4500000017",
  "DocumentDate": "2019-08-06T00:00:00",
  "PostingDate": "2019-08-06T00:00:00",
  "SourceOfGR": "PURORD",
  "DeliveryDocumentByVendor": "",
  "MaterialDocumentHeaderText": "",
  "Temp_Key": "4500000017GR06082019150400",
  "BillOfLading": "",
  "VersionForPrintingSlip": "0",
  "Header2Items": [
    {
      "Material": "OHMT1013",
      "InboundDelivery": "4500000017",
      "DeliveryDocumentItem": "000010",
      "DocumentItemText": "",
      "QuantityInEntryUnit": "10",
      "EntryUnit": "EA",
      "OpenQuantity": "10",
      "UnitOfMeasure": "EA",
      "Plant": "MI00",
      "StorageLocation": "TG00",
      "StockType": "",
      "Batch": "",
      "AcctAssignmentCategory": "",
      "AssetNumber": "",
      "AssetNumberName": "",
      "SubAssetNumber": "",
      "GLAccount": "",
      "GLAccountName": "",
      "Project": "",
      "ProjectDescription": "",
      "GoodsMovementReasonCode": "0000"
    }
  ]
}
```

The minimal complete request looks like this:

```
curl -X POST \
  'http://sap.system.edu:port/sap/opu/odata/sap/MMIM_GR4PO_DL_SRV/GR4PO_DL_Headers?sap-client=XXX' \
  -H 'Authorization: Basic ABCDEFGHIJKLMNOPQRSTUW==' \
  -H 'Content-Type: application/json' \
  -H 'x-csrf-token: abcdefghijklmnopqustuw==' \
  -d '{"InboundDelivery":"4500000017","DocumentDate":"2019-08-06T00:00:00","PostingDate":"2019-08-06T00:00:00","SourceOfGR":"PURORD","DeliveryDocumentByVendor":"","MaterialDocumentHeaderText":"","Temp_Key":"4500000017GR06082019150400","BillOfLading":"","VersionForPrintingSlip":"0","Header2Items":[{"Material":"OHMT1013","InboundDelivery":"4500000017","DeliveryDocumentItem":"000010","DocumentItemText":"","QuantityInEntryUnit":"10","EntryUnit":"EA","OpenQuantity":"10","UnitOfMeasure":"EA","Plant":"MI00","StorageLocation":"TG00","StockType":"","Batch":"","AcctAssignmentCategory":"","AssetNumber":"","AssetNumberName":"","SubAssetNumber":"","GLAccount":"","GLAccountName":"","Project":"","ProjectDescription":"","GoodsMovementReasonCode":"0000"}]}'
```

The response will look like this. Essentially, the response contains the posted document.

```
<?xml version="1.0" encoding="utf-8"?>
<entry xml:base="http://sap.system.edu:port/sap/opu/odata/sap/MMIM_GR4PO_DL_SRV/" xmlns="http://www.w3.org/2005/Atom" xmlns:m="http://schemas.microsoft.com/ado/2007/08/dataservices/metadata" xmlns:d="http://schemas.microsoft.com/ado/2007/08/dataservices">
    <id>http://sap.system.edu:port/sap/opu/odata/sap/MMIM_GR4PO_DL_SRV/GR4PO_DL_Headers(InboundDelivery='4500000017',SourceOfGR='PURORD')</id>
    <title type="text">GR4PO_DL_Headers(InboundDelivery='4500000017',SourceOfGR='PURORD')</title>
    <updated>2019-08-07T03:23:46Z</updated>
    <category term="MMIM_GR4PO_DL_SRV.GR4PO_DL_Header" scheme="http://schemas.microsoft.com/ado/2007/08/dataservices/scheme"/>
    <link href="GR4PO_DL_Headers(InboundDelivery='4500000017',SourceOfGR='PURORD')" rel="edit" title="GR4PO_DL_Header"/>
    <link href="GR4PO_DL_Headers(InboundDelivery='4500000017',SourceOfGR='PURORD')/Header2Items" rel="http://schemas.microsoft.com/ado/2007/08/dataservices/related/Header2Items" type="application/atom+xml;type=feed" title="Header2Items">
        <m:inline>
            <feed xml:base="http://sap.system.edu:port/sap/opu/odata/sap/MMIM_GR4PO_DL_SRV/">
                <id>http://sap.system.edu:port/sap/opu/odata/sap/MMIM_GR4PO_DL_SRV/GR4PO_DL_Headers(InboundDelivery='4500000017',SourceOfGR='PURORD')/Header2Items</id>
                <title type="text">GR4PO_DL_Items</title>
                <updated>2019-08-07T03:23:46Z</updated>
                <author>
                    <name/>
                </author>
                <link href="GR4PO_DL_Headers(InboundDelivery='4500000017',SourceOfGR='PURORD')/Header2Items" rel="self" title="GR4PO_DL_Items"/>
                <entry>
                    <id>http://sap.system.edu:port/sap/opu/odata/sap/MMIM_GR4PO_DL_SRV/GR4PO_DL_Items(InboundDelivery='4500000017',DeliveryDocumentItem='000010',SourceOfGR='')</id>
                    <title type="text">GR4PO_DL_Items(InboundDelivery='4500000017',DeliveryDocumentItem='000010',SourceOfGR='')</title>
                    <updated>2019-08-07T03:23:46Z</updated>
                    <category term="MMIM_GR4PO_DL_SRV.GR4PO_DL_Item" scheme="http://schemas.microsoft.com/ado/2007/08/dataservices/scheme"/>
                    <link href="GR4PO_DL_Items(InboundDelivery='4500000017',DeliveryDocumentItem='000010',SourceOfGR='')" rel="edit" title="GR4PO_DL_Item"/>
                    <link href="GR4PO_DL_Items(InboundDelivery='4500000017',DeliveryDocumentItem='000010',SourceOfGR='')/Item2StockTypes" rel="http://schemas.microsoft.com/ado/2007/08/dataservices/related/Item2StockTypes" type="application/atom+xml;type=feed" title="Item2StockTypes"/>
                    <content type="application/xml">
                        <m:properties>
                            <d:InboundDelivery>4500000017</d:InboundDelivery>
                            <d:DeliveryDocumentItem>000010</d:DeliveryDocumentItem>
                            <d:SourceOfGR/>
                            <d:AcctAssignmentCategory/>
                            <d:AcctAssignmentCategoryName/>
                            <d:Plant>MI00</d:Plant>
                            <d:PlantName/>
                            <d:StorageLocation>TG00</d:StorageLocation>
                            <d:StorageLocationName/>
                            <d:Material>OHMT1013</d:Material>
                            <d:MaterialName/>
                            <d:PurchaseOrderItemText/>
                            <d:Batch/>
                            <d:OrderedQuantity>0.000</d:OrderedQuantity>
                            <d:OrderedQuantityUnit/>
                            <d:OpenQuantity>10</d:OpenQuantity>
                            <d:UnitOfMeasure>EA</d:UnitOfMeasure>
                            <d:QuantityInEntryUnit>10</d:QuantityInEntryUnit>
                            <d:EntryUnit>EA</d:EntryUnit>
                            <d:StockType/>
                            <d:StockTypeName/>
                            <d:Project/>
                            <d:ProjectDescription/>
                            <d:GLAccount/>
                            <d:GLAccountName/>
                            <d:UnloadingPointName/>
                            <d:GoodsRecipientName/>
                            <d:DeliveryCompleted/>
                            <d:FunctionalArea/>
                            <d:ProfitCenter/>
                            <d:ProfitCenterName/>
                            <d:CostCenter/>
                            <d:CostCenterName/>
                            <d:SalesOrder/>
                            <d:SalesOrderItem>000000</d:SalesOrderItem>
                            <d:DocumentItemText/>
                            <d:OrderID/>
                            <d:InventorySpecialStockType/>
                            <d:InventorySpecialStockTypeName/>
                            <d:IsConsumptionMovement>false</d:IsConsumptionMovement>
                            <d:GoodsMovementReasonCode>0000</d:GoodsMovementReasonCode>
                            <d:AssetNumber/>
                            <d:AssetNumberName/>
                            <d:SubAssetNumber/>
                        </m:properties>
                    </content>
                </entry>
            </feed>
        </m:inline>
    </link>
    <content type="application/xml">
        <m:properties>
            <d:InboundDelivery>4500000017</d:InboundDelivery>
            <d:SourceOfGR>PURORD</d:SourceOfGR>
            <d:PurchasingDocumentType/>
            <d:PurchasingDocumentTypeName/>
            <d:DocumentDate>2019-08-06T00:00:00</d:DocumentDate>
            <d:PostingDate>2019-08-06T00:00:00</d:PostingDate>
            <d:DeliveryDocumentByVendor/>
            <d:BillOfLading/>
            <d:Vendor/>
            <d:VendorName/>
            <d:SupplyingPlant/>
            <d:SupplyingPlantName/>
            <d:MaterialDocumentHeaderText/>
            <d:Temp_Key>4500000017GR06082019150400</d:Temp_Key>
            <d:VersionForPrintingSlip>0</d:VersionForPrintingSlip>
        </m:properties>
    </content>
</entry>
```

Furthermore, check the header information of the response. It should contain a header called `sap-message`. Posting of goods receipt was successful, if the message looks like the following. Please note the material document number.

```
<notification xmlns:sap="http://www.sap.com/Protocols/SAPData">
  <code>MIGO/012</code>
  <message>Material document 5000000348 2019 posted</message>
  <longtext_url>/sap/opu/odata/iwbep/message_text;o=LOCAL/</longtext_url>
  <severity>info</severity>
  <target></target>
  <details/>
</notification>
```

### Use the Web GUI of the SAP system to explore the completed purchase order

In the Web GUI, use the transaction code `ME23N` to display an existing purchase order document.

![ME21N](img/me23n.png)

Once you see the purchase order, scroll down to the items and select `Purchase Order History`. You should now see a material document listed.

![Listed material documents](img/display_po.png)

## Summary

Congratulations, you have completed a goods receipt transaction!

The challenge of directly using the API endpoints of an SAP system lies in understanding the order and meaning of the specific calls that are required to perform an business activity. In comparison, the technical implementation is pretty straight forward. More about this [here](SAP_oData.md).
