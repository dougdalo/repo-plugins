transforms=wrap
transforms.wrap.type=org.apache.kafka.connect.transforms.HoistField$Value
transforms.wrap.field=payload


"transforms": "insertOp",
  "transforms.insertOp.type": "org.apache.kafka.connect.transforms.InsertField$Value",
  "transforms.insertOp.static.field": "op",
  "transforms.insertOp.static.value": "c"


"transforms": "wrap,insertOp",
  "transforms.wrap.type": "org.apache.kafka.connect.transforms.HoistField$Value",
  "transforms.wrap.field": "after",
  "transforms.insertOp.type": "org.apache.kafka.connect.transforms.InsertField$Value",
  "transforms.insertOp.static.field": "op",
  "transforms.insertOp.static.value": "c"



"transforms": "fixDecimal",
"transforms.fixDecimal.type": "org.apache.kafka.connect.transforms.RegexRouter",
"transforms.fixDecimal.regex": ",",
"transforms.fixDecimal.replacement": "."


"transforms": "fixDecimal,wrapToAfter,insertOp",

"transforms.fixDecimal.type": "org.apache.kafka.connect.transforms.Script$Value",
"transforms.fixDecimal.language": "javascript",
"transforms.fixDecimal.script": "if (value.VLR_LCT) value.VLR_LCT = value.VLR_LCT.replace(',', '.'); value;"
