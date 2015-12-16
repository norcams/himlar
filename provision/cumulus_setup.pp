user { "iaas":
  ensure     => "present",
  managehome => true,
  groups     => [ "sudo" ],
  password   => "!", # locked, no password
}

ssh_authorized_key { "iaas-on-iaas":
  ensure => "present",
  type   => "ssh-rsa",
  key    => "AAAAB3NzaC1yc2EAAAADAQABAAABAQC+OF1sQvpZdYhxVJgrd+1P84/AegFJHY5W0SLIO8dF4K6CP08bJNwg+5eD8kxebmoXTJlfIRC1onJfjDPl94x9F3x18zib3kiSIPnkN7BsCZIxTcN1czHRUEtyOPG9JlKCagaXwHkBIzYIngF9hwBix9ZetuYieiZU/rhnk7x/zNxmjqPBf26rEI1qk4S6xYoAJjx0YFUbLYYiqc7YxGypo0ag99nKaZpy2p5mMyYGn4nGmlCzSG+aANokvlz8gwVzThaIPB8s0YYdXf1w/1OdFcUuW8Wm3AonFZcVhGfJy3yaAZDvbpWI1JVbJ9hMOo5Tml6nx8FM8MU6mAoamgRT",
  user   => "iaas",
}

# sudoers temp hack
exec { "allow nopasswd for sudo group":
  command => "echo '%sudo ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/iaas",
  creates => "/etc/sudoers.d/iaas",
  path => [ "/bin", "/usr/bin" ],
}

