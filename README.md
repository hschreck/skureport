# skureport
A Ruby script used for gathering specific data from SkuVault without accessing their API

Uses Pony and Mechanize gems

```
gem install mechanize
gem install pony
```

Modify config.example.rb and rename to config.rb

EMAIL fields are fields use in the Pony gem (TO, FROM, SENDER, CC, Attachment Prefix, etc)

Username and password fields are for SkuVault

Modify SKU.example.txt and rename to SKU.txt

Run skuvault.rb `ruby skuvault.rb`
