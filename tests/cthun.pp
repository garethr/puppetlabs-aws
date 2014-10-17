Ec2_securitygroup {
  region => 'eu-west-1',
}

Ec2_instance {
  image_id        => ' ami-a5ad56d2', # Fedora 20,
  region            => 'eu-west-1',
  availability_zone => 'eu-west-1a',
  tags            => {
    department => 'engineering',
    project    => 'cthun',
    created_by => 'parisiale'
  },
  monitoring      => true,
  key_name        => 'parisiale-cthun',
  security_groups => ['cthun-sg'],
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
  user_data     => template('puppetlabs-aws/cthun-master.sh.erb'),
}

ec2_instance { 'cthun-test':
  ensure        => present,
  instance_type => 't1.micro',
  user_data     => template('puppetlabs-aws/cthun-test.sh.erb'),
}
