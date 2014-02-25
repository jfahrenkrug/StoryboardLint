require 'spec_helper'

describe StoryboardLint::StoryboardScanner do
  
  before :all do
    @sbs = StoryboardLint::StoryboardScanner.new(File.join(File.dirname(__FILE__), "fixtures", "StoryboardLintTest"))
  end
  
  it "should require an existing path when being initialized" do
    expect {StoryboardLint::StoryboardScanner.new("/some/path/that/does/not/exist")}.to raise_error
    expect {StoryboardLint::StoryboardScanner.new(File.dirname(__FILE__))}.to_not raise_error
  end
  
  it "should find the storyboard files in the directory" do
    sb_files = @sbs.storyboard_files
    sb_files.size.should == 2
    File.basename(sb_files[0]).should == "Main_iPad.storyboard"
    File.basename(sb_files[1]).should == "Main_iPhone.storyboard"
  end
  
  it "should return the segue IDs" do
    ids = @sbs.segue_ids
    ids.size.should == 1
    ids[0][:id].should == "seg_showDetailSegue"
  end
  
  it "should return the storyboard IDs" do
    ids = @sbs.storyboard_ids
    ids.size.should == 3
    ids[0][:id].should == 'sb_navigationControllerStoryboard'
    ids[1][:id].should == 'sb_masterControllerStoryboard'
    ids[2][:id].should == 'sb_detailControllerStoryboard'
  end
  
  it "should return the reuse IDs" do
    ids = @sbs.reuse_ids
    ids.size.should == 2
    ids[0][:id].should == "Cell"
    ids[1][:id].should == "ruid_TableCell"
  end
  
  it "should return the custom class names" do
    names = @sbs.custom_class_names
    names.size.should == 5
    name_strings = names.map {|item| item[:class_name]}
    name_strings.should include('SPWKMasterViewController')
    name_strings.should include('SPWKDetailViewController')
    name_strings.should include('NonexistentViewController')
  end
  
end