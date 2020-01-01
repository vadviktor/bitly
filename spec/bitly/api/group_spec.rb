# frozen_string_literal: true

RSpec.describe Bitly::API::Group do
  let(:group_data) {
    {
      "created"=>"2009-01-08T07:11:59+0000",
      "modified"=>"2016-11-11T23:48:07+0000",
      "bsds"=>[],
      "guid"=>"def456",
      "organization_guid"=>"abc123",
      "name"=>"philnash",
      "is_active"=>true,
      "role"=>"org-admin",
      "references"=>{
        "organization"=>"https://api-ssl.bitly.com/v4/organizations/abc123"
      }
    }
  }

  it "uses a client to list groups" do
    response = Bitly::HTTP::Response.new(
      status: "200",
      body: { "groups" => [group_data] }.to_json,
      headers: {}
    )
    client = double("client")
    expect(client).to receive(:request)
      .with(path: "/groups", params: {})
      .and_return(response)

    groups = Bitly::API::Group.list(client)
    expect(groups.count).to eq(1)
    expect(groups.first).to be_instance_of(Bitly::API::Group)
    expect(groups.response).to eq(response)
  end

  it "can list groups filtered by organization" do
    response = Bitly::HTTP::Response.new(
      status: "200",
      body: { "groups" => [group_data] }.to_json,
      headers: {}
    )
    client = double("client")
    expect(client).to receive(:request)
      .with(path: "/groups", params: { "organization_guid" => "abc123" })
      .and_return(response)
    organization = Bitly::API::Organization.new({"guid" => "abc123"}, client: client)
    groups = Bitly::API::Group.list(client, organization: organization)
    expect(groups.count).to eq(1)
    expect(groups.first).to be_instance_of(Bitly::API::Group)
    expect(groups.response).to eq(response)
  end

  it "can list groups filtered by organization guid" do
    response = Bitly::HTTP::Response.new(
      status: "200",
      body: { "groups" => [group_data] }.to_json,
      headers: {}
    )
    client = double("client")
    expect(client).to receive(:request)
      .with(path: "/groups", params: { "organization_guid" => "abc123" })
      .and_return(response)
    groups = Bitly::API::Group.list(client, organization: "abc123")
    expect(groups.count).to eq(1)
    expect(groups.first).to be_instance_of(Bitly::API::Group)
    expect(groups.response).to eq(response)
  end

  it "can use a client to fetch a group with an guid" do
    response = Bitly::HTTP::Response.new(
      status: "200",
      body: group_data.to_json,
      headers: {}
    )
    client = double("client")
    expect(client).to receive(:request).with(path: "/groups/def456").and_return(response)
    group = Bitly::API::Group.fetch(client, "def456")
    expect(group.name).to eq("philnash")
    expect(group.role).to eq("org-admin")
  end

  describe "with a group" do
    let(:client) { double("client") }
    let(:organization) { double("organization") }

    it "can fetch its organization" do
      expect(Bitly::API::Organization).to receive(:fetch)
        .with(client, "abc123")
        .and_return(organization)
      group = Bitly::API::Group.new(group_data, client: client)
      expect(group.organization).to eq(organization)
    end

    it "doesn't fetch the organization if it already has it" do
      group = Bitly::API::Group.new(group_data, client: client, organization: organization)
      expect(Bitly::API::Organization).not_to receive(:fetch)
      group.organization
    end

    it "doesn't fetch the organization more than once" do
      expect(Bitly::API::Organization).to receive(:fetch).once
        .with(client, "abc123")
        .and_return(organization)
      group = Bitly::API::Group.new(group_data, client: client)
      group.organization
      group.organization
    end
  end
end