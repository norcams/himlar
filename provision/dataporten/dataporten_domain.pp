keystone_domain { "dataporten":
  ensure       => present,
  description => "Federated users from Dataporten",
  is_default  => false,
}

#keystone_tenant { "demo":
#  ensure      => present,
#  description => "Dataporten demo project",
#  domain      => "dataporten",
#  enabled     => True,
#}
