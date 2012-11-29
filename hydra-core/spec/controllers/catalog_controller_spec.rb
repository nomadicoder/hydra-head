require 'spec_helper'

# See cucumber tests (ie. /features/edit_document.feature) for more tests, including ones that test the edit method & view
# You can run the cucumber tests with 
#
# cucumber --tags @edit
# or
# rake cucumber

describe CatalogController do
  
  before do
    session[:user]='bob'
  end
  
  it "should use CatalogController" do
    controller.should be_an_instance_of(CatalogController)
  end
  
  
  describe "Paths Generated by Custom Routes:" do
    # paths generated by custom routes
    it "should map {:controller=>'catalog', :action=>'index'} to GET /catalog" do
      { :get => "/catalog" }.should route_to(:controller => 'catalog', :action => 'index')
    end
    it "should map {:controller=>'catalog', :action=>'show', :id=>'test:3'} to GET /catalog/test:3" do
      { :get => "/catalog/test:3" }.should route_to(:controller => 'catalog', :action => 'show', :id=>'test:3')
    end

    it "should map catalog_path" do
      # catalog_path.should == '/catalog'
      catalog_path("test:3").should == '/catalog/test:3'
    end
  end
  
  it "should not choke on objects with periods in ids (ie Fedora system objects)" do    
     pending "Need to override blacklight routes"	

	## We could do something like this to remove the catalog/show route and replace it with a route that allows dots (e.g. resources :catalog, :id=> /.+/)
	  # def add_route
	  #   new_route = ActionController::Routing::Routes.builder.build(name, route_options)
	  #   ActionController::Routing::Routes.routes.insert(0, new_route)
	  # end

	  # def remove_route
	  #   ActionController::Routing::Routes.routes.reject! { |r| r.instance_variable_get(:@requirements)[:slug_id] == id }
	  # end

    catalog_path("fedora-system:FedoraObject-3.0").should == '/catalog/fedora-system:FedoraObject-3.0'
    { :get => "/catalog/fedora-system:FedoraObject-3.0" }.should route_to(:controller => 'catalog', :action => 'show', :id=>'fedora-system:FedoraObject-3.0')
  end
  
  describe "index" do
    
    describe "access controls" do
      before(:all) do
        fq = "read_access_group_t:public OR edit_access_group_t:public OR discover_access_group_t:public"
        solr_opts = {:fq=>fq}
        response = Blacklight.solr.get('select', :params=> solr_opts)
        @public_only_results = Blacklight::SolrResponse.new(response, solr_opts)
      end

      it "should only return public documents if role does not have permissions" do
        controller.stub(:current_user).and_return(nil)
        get :index
        assigns(:document_list).count.should == @public_only_results.docs.count
      end
    end
  end
  
  describe "filters" do
    describe "index" do
      it "should trigger enforce_index_permissions" do
        controller.should_receive(:add_access_controls_to_solr_params)
        get :index
      end
    end
    describe "show" do
      it "should trigger enforce_show_permissions" do
        controller.stub(:current_user).and_return(nil)
        controller.should_receive(:enforce_show_permissions)
        get :show, :id=>'test:3'
      end
    end
  end
  
end
