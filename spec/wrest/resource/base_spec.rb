require File.dirname(__FILE__) + '/../../spec_helper'

class Glassware < Wrest::Resource::Base
  set_host "http://localhost:3000"
end

class BottledUniverse < Glassware
  set_host "http://localhost:3001"
end

module Wrest
  describe Resource::Base do
    it "should not affect other classes when setting up its macros" do
      Class.should_not respond_to(:host=)
      Object.should_not respond_to(:host=)
    end

    it "should not affect itself when subclasses use its macros" do
      Resource::Base.should_not respond_to(:host)
    end

    describe 'subclasses' do
      before(:each) do
        @BottledUniverse = Class.new(Resource::Base)
        @BottledUniverse.class_eval do
          set_resource_name 'BottledUniverse'
        end
      end

      it "should know its name as a resource by default" do
        BottledUniverse.resource_name.should == 'BottledUniverse'
      end

      it "should allow its name as a resource to be configured for anonymous classes" do
        @BottledUniverse.resource_name.should == 'BottledUniverse'
      end

      it "should know how to create an instance using deserialised attributes" do
        # Json => {"lead_bottle"=>{"name"=>"Wooz", "id"=>1, "universe_id"=>nil}}
        # Xml =>  {"lead-bottle"=>[{"name"=>["Wooz"], "universe-id"=>[{"type"=>"integer", "nil"=>"true"}], "id"=>[{"type"=>"integer", "content"=>"1"}]}]}
        universe = @BottledUniverse.new "name"=>"Wooz", "id"=>'1', "universe_id"=>nil, 'owner_id'=>nil
        universe.name.should == "Wooz"
        universe.owner_id.should be_nil
        universe.id.should == 1
      end

      it "should allow instantiation with no attributes" do
        lambda{ @BottledUniverse.new }.should_not raise_error
      end

      it "should have a method to set the host url" do
        @BottledUniverse.should respond_to(:set_host)
      end

      it "should have a method to retrive the host url after it is set" do
        @BottledUniverse.class_eval{ set_host "http://localhost:3000" }
        @BottledUniverse.should respond_to(:host)
      end

      it "should know what its site is" do
        @BottledUniverse.class_eval{ set_host "http://localhost:3000" }
        @BottledUniverse.host.should == "http://localhost:3000"
      end

      it "should not use the same string" do
        url = "http://localhost:3000"
        @BottledUniverse.class_eval{ set_host  url }
        url.upcase!
        @BottledUniverse.host.should == "http://localhost:3000"
      end

      it "should know its resource path" do
        Glassware.resource_path.should == '/glasswares'
      end
    end

    describe 'subclasses of sublasses' do
      it "should configure its host without affecting its superclass" do
        Glassware.host.should == "http://localhost:3000"
        BottledUniverse.host.should == "http://localhost:3001"
      end

      it "should know its resource path when it is a subclass of a subclass" do
        BottledUniverse.resource_path.should == '/bottled_universes'
      end
    end

    describe 'attribute interface' do
      it "should fail when getter methods for attributes that don't exist are invoked" do
        universe = Glassware.new(:owner => 'Kai Wren', :guardian => 'Lung Shan')
        lambda{ universe.ooga }.should raise_error(NoMethodError)
      end

      it "should provide getter methods for attributes" do
        universe = Glassware.new(:owner => 'Kai Wren', :guardian => 'Lung Shan')
        universe.owner.should == 'Kai Wren'
        universe.guardian.should == 'Lung Shan'
      end

      it "should respond to getter methods for attributes" do
        universe = Glassware.new(:owner => 'Kai Wren', :guardian => 'Lung Shan')
        universe.should respond_to(:owner)
        universe.should respond_to(:guardian)
      end

      it "should not respond to getter methods for attributes that don't exist" do
        universe = Glassware.new(:owner => 'Kai Wren', :guardian => 'Lung Shan')
        universe.should_not respond_to(:theronic)
      end

      it "should create a setter method when one is invoked for attributes that don't exist" do
        universe = Glassware.new(:owner => 'Kai Wren', :guardian => 'Lung Shan')
        universe.fu_dog = 'Shiriki'
        universe.attributes[:fu_dog].should == 'Shiriki'
        universe.fu_dog.should == 'Shiriki'
      end

      it "should provide setter methods for attributes" do
        universe = Glassware.new(:owner => 'Kai Wren', :guardian => 'Lung Shan')
        universe.guardian = 'Effervescent Tiger'
        universe.attributes[:guardian].should == 'Effervescent Tiger'
      end

      it "should respond to setter methods for attributes" do
        universe = Glassware.new(:owner => 'Kai Wren', :guardian => 'Lung Shan')
        universe.should respond_to(:owner=)
        universe.should respond_to(:guardian=)
      end

      it "should not respond to setter methods for attributes that don't exist" do
        universe = Glassware.new(:owner => 'Kai Wren', :guardian => 'Lung Shan')
        universe.should_not respond_to(:theronic=)
      end

      it "should fail when query methods for attributes that don't exist are invoked" do
        universe = Glassware.new(:owner => 'Kai Wren', :guardian => 'Lung Shan')
        lambda{ universe.ooga? }.should raise_error(NoMethodError)
      end

      it "should provide query methods for attributes" do
        universe = Glassware.new(:owner => 'Kai Wren', :guardian => nil)
        universe.owner?.should be_true
        universe.guardian?.should be_false
      end

      it "should respond to query methods for attributes" do
        universe = Glassware.new(:owner => 'Kai Wren', :guardian => 'Lung Shan')
        universe.should respond_to(:owner?)
        universe.should respond_to(:guardian?)
      end

      it "should not respond to query methods for attributes that don't exist" do
        universe = Glassware.new(:owner => 'Kai Wren', :guardian => 'Lung Shan')
        universe.should_not respond_to(:theronic?)
      end
    end
  end
end
