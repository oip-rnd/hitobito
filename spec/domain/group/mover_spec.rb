require 'spec_helper'
describe Group::Mover do

  let(:move) { Group::Mover.new(group) }

  describe "#ability" do
    let(:user) { people(:top_leader) }
    subject {  Ability.new(user) }

    it "top_leader" do
      should be_able_to(:move, groups(:bottom_group_one_one), groups(:bottom_layer_two))
    end

  end

  describe "#candidates" do
    subject { Group::Mover.new(group) }

    context "top_group" do
      let(:group) { groups(:top_group) }
      its(:candidates) { should be_blank }
    end

    context "bottom_layer_one" do
      let(:group) { groups(:bottom_layer_one) }
      its(:candidates) { should be_blank }
    end

    context "bottom_layer_two" do
      let(:group) { groups(:bottom_layer_two) }
      its(:candidates) { should be_blank }
    end

    context "bottom_group_one_one" do
      let(:group) { groups(:bottom_group_one_one) }
      its(:candidates) { should =~ groups_for(:bottom_layer_two, :bottom_group_one_two) }
    end

    context "bottom_group_one_two" do
      let(:group) { groups(:bottom_group_one_two) }
      its(:candidates) { should =~ groups_for(:bottom_layer_two, :bottom_group_one_one) }

    end

    context "bottom_group_two_one" do
      let(:group) { groups(:bottom_group_two_one) }
      its(:candidates) { should =~ groups_for(:bottom_layer_one) }
    end

    def groups_for(*args)
      args.map { |arg| groups(arg) }
    end
  end

  context "#perform" do
    let(:group) { groups(:bottom_group_one_one) }
    let(:target) { groups(:bottom_layer_two) }

    context "moved group" do
      subject { group.reload }
      before { move.perform(target); }

      its(:parent) { should eq target }
    end

    context "association count" do
      before do
        event = Fabricate(:event, groups: [group])
        Fabricate(:event_participation, event: event)
        Fabricate(Group::BottomGroup::Member.name.to_s, group: group)
      end

      [Group, Role, Person, Event, Event::Participation].each do |model|
        it "does not change #{model} count" do
          expect { move.perform(target) }.not_to change(model,:count)
        end
      end
    end
  end

end

