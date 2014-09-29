require_relative '../../../puppet_x/puppetlabs/aws.rb'
require "base64"

Puppet::Type.type(:ec2_instance).provide(:v2) do
  confine feature: :aws

  mk_resource_methods

  def self.instances
    region = ENV['AWS_REGION']
    client = PuppetX::Puppetlabs::Aws.ec2_client(region: region)
    response = client.describe_instances(filters: [
      {name: 'instance-state-name', values: ['pending', 'running']}
    ])
    instances = []
    response.data.reservations.each do |reservation|
      reservation.instances.each do |instance|
        instances << new({
          name: instance.tags.map { |tag| tag.value if tag.key=='Name' }.first,
          instance_type: instance.instance_type,
          image_id: instance.image_id,
          availability_zone: instance.placement.availability_zone,
          ensure: :present,
          region: region
        })
      end
    end
    instances
  end

  def self.prefetch(resources)
    instances.each do |prov|
      if resource = resources[prov.name]
        resource.provider = prov
      end
    end
  end

  def client
    region = resource[:region] || ENV['AWS_REGION']
    PuppetX::Puppetlabs::Aws.ec2_client(region: region)
  end

  def _find_instances
    client.describe_instances(filters: [
      {name: 'tag:Name', values: [name]},
      {name: 'instance-state-name', values: ['pending', 'running']}
    ])
  end

  def exists?
    Puppet.info("Checking if instance #{name} exists")
    @property_hash[:ensure] == :present
  end

  def create
    Puppet.info("Creating instance #{name}")
    groups = resource[:security_groups]
    groups = [groups] unless groups.is_a?(Array)

    response = client.run_instances(
      image_id: resource[:image_id],
      min_count: 1,
      max_count: 1,
      security_groups: groups,
      instance_type: resource[:instance_type],
      user_data: Base64.encode64(resource[:user_data]),
      placement: {
        availability_zone: resource[:availability_zone]
      }
    )
    tags = resource[:tags].map { |k,v| {key: k, value: v} }
    tags << {key: 'Name', value: name}
    client.create_tags(
      resources: response.instances.map(&:instance_id),
      tags: tags
    )
  end

  def destroy
    Puppet.info("Deleting instance #{name}")
    client.terminate_instances(
      instance_ids: _find_instances.reservations.map(&:instances).
        flatten.map(&:instance_id)
    )
  end
end

