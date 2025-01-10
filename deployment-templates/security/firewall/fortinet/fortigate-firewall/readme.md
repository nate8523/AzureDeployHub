Get-AzMarketplaceTerms `
  -Publisher 'fortinet' `
  -Product 'fortinet_fortigate-vm_v5' `
  -Name 'fortinet_fg-vm' `
  -OfferType 'virtualmachine' | Set-AzMarketplaceTerms -Accept