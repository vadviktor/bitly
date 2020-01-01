# frozen_string_literal: true

RSpec.describe Bitly::API::Organization do
  let(:organization_data) {
    {
      "created" => "2009-01-08T07:11:59+0000",
      "modified" => "2016-11-11T23:48:07+0000",
      "bsds" => [],
      "guid" => "abc123",
      "name" => "testorg",
      "is_active" => true,
      "tier" => "free",
      "tier_family" => "free",
      "tier_display_name" => "Free",
      "role" => "admin",
      "references":{
        "groups":"https://api-ssl.bitly.com/v4/groups?organization_guid=abc123"
      }
    }
  }

  it "uses a client to list organizations" do
    response = Bitly::HTTP::Response.new(
      status: "200",
      body: { "organizations" => [organization_data] }.to_json,
      headers: {}
    )
    client = double("client")
    expect(client).to receive(:request).with(path: "/organizations").and_return(response)

    organizations = Bitly::API::Organization.list(client)
    expect(organizations.count).to eq(1)
    expect(organizations.first).to be_instance_of(Bitly::API::Organization)
    expect(organizations.response).to eq(response)
  end

  it "can get organizations by guid" do
    response = Bitly::HTTP::Response.new(
      status: "200",
      body: organization_data.to_json,
      headers: {}
    )
    client = double("client")
    expect(client).to receive(:request).with(path: "/organizations/abc123").and_return(response)
    organization = Bitly::API::Organization.fetch(client, "abc123")
    expect(organization.tier).to eq("free")
    expect(organization.name).to eq("testorg")
  end

  describe "with an organization" do
    let(:client) { double("client") }
    let(:groups) { double("groups") }
    let(:organization) { Bitly::API::Organization.new(organization_data, client: client) }

    it "can fetch groups filtered by guid" do
      expect(Bitly::API::Group).to receive(:list)
        .with(client, organization: organization)
        .and_return(groups)
      expect(organization.groups).to eq(groups)
    end

    it "doesn't fetch groups if they have already been fetched" do
      expect(Bitly::API::Group).to receive(:list).once
        .with(client, organization: organization)
        .and_return(groups)
      organization.groups
      organization.groups
    end
  end
end