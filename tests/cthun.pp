Ec2_securitygroup {
  region => 'eu-west-1',
}

Ec2_instance {
  image_id          => 'ami-7efe5009', # Fedora 20,
  region            => 'eu-west-1',
  availability_zone => 'eu-west-1a',
  tags              => {
    department => 'engineering',
    project    => 'cthun',
    created_by => 'parisiale'
  },
  monitoring        => true,
  key_name          => 'parisiale-cthun',
  security_groups   => ['cthun-sg'],
}

ec2_securitygroup { 'cthun-sg':
  ensure      => present,
  description => 'Security group for cthun load testing',
  ingress     => [{
    protocol => 'tcp',
    port     => 22,
    cidr     => '0.0.0.0/0'
  }],
}

ec2_instance { 'cthun-master':
  ensure        => present,
  instance_type => 'c1.medium',
}

ec2_instance { ['cthun-test', 'cthun-test-2']:
  ensure        => present,
  instance_type => 't1.micro',
}
