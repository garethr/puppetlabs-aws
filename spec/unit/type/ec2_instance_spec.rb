require 'spec_helper'

type_class = Puppet::Type.type(:ec2_instance)

describe type_class do

  let :params do
    [
      :name,
      :instance_initiated_shutdown_behavior,
    ]
  end

  let :properties do
    [
      :ensure,
      :security_groups,
      :image_id,
      :instance_type,
      :region,
      :availability_zone,
      :monitoring,
      :key_name,
      :subnet,
      :ebs_optimized,
    ]
  end

  it 'should have expected properties' do
    properties.each do |property|
      expect(type_class.properties.map(&:name)).to be_include(property)
    end
  end

  it 'should have expected parameters' do
    params.each do |param|
      expect(type_class.parameters).to be_include(param)
    end
  end

  it 'should support :stopped as a value to :ensure' do
    type_class.new(:name => 'sample', :ensure => :stopped)
  end

  it 'should support :running as a value to :ensure' do
    type_class.new(:name => 'sample', :ensure => :running)
  end

  it 'should default monitoring to false' do
    srv = type_class.new(:name => 'sample')
    expect(srv[:monitoring]).to eq(:false)
  end

  it 'should default ebs obtimized to false' do
    srv = type_class.new(:name => 'sample')
    expect(srv[:monitoring]).to eq(:false)
  end

  it 'should default instance_initiated_shutdown_behavior to stop' do
    srv = type_class.new(:name => 'sample')
    expect(srv[:instance_initiated_shutdown_behavior]).to eq(:stop)
  end

  it 'should order tags on output' do
    expect(type_class).to order_tags_on_output
  end
end
