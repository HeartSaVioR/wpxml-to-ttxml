# TTXML 정보를 파일로 기록하는 클래스
# Jungtaek Lim(Heart)

require 'rexml/document'
include REXML

require 'rexml_util'
include REXMLUtil

# TTXML 정보를 파일로 기록하는 클래스
class TTXMLWriter

  # tt_categories : 카테고리 리스트 // Array of TTCategory
  # tt_posts : 포스트 리스트 // Array of TTPost
  def initialize(tt_categories, tt_posts)
    # tt_categories 는 TTCategory 만 들어가 있어야 함
    # tt_posts 는 TTPost 만 들어가 있어야 함
    @categories = tt_categories
    @posts = tt_posts

  end

  # TTXML 정보를 실제 파일로 기록
  # file_path : 파일 경로 // String
  def write_to_file(file_path)
    return if (@categories == nil || @posts == nil)

    ttxml_doc = get_ttxml_document

    file = File.new(file_path, 'w')
    file.puts ttxml_doc
    file.close

  end

  private

  # 객체 생성시 받은 정보를 토대로 TTXML 내용(XML)을 만든다
  def get_ttxml_document
    # Write To XML
    template_str = "<?xml version='1.0' encoding='utf-8' ?> <blog type='tattertools/1.0' migrational='false'> </blog> "
    doc_tt = Document.new template_str
    
    blog_tag = doc_tt.root
    
    cat_no = 1
    categories = @categories
    
    categories.each do |category|
      category_tag = Element.new "category"
      
      category_tag.add_element make_xml_element("name", category.name)
      category_tag.add_element make_xml_element("priority", cat_no)
      
      cat_no += 1
      
      category.children.each do |child_cat|
        child_category_tag = Element.new "category"
        
        child_category_tag.add_element make_xml_element("name", child_cat)
        child_category_tag.add_element make_xml_element("priority", cat_no)
        
        cat_no += 1
        
        category_tag.add_element child_category_tag
      end
      
      blog_tag.add_element category_tag
      
    end
    
    posts = @posts
    
    posts.each do |post|
      post_tag = Element.new "post"
      
      post_tag.add_element make_xml_element("slogal", post.title)
      post_tag.add_element make_xml_element("id", post.id)
      post_tag.add_element make_xml_element("visibility", post.visibility)
      post_tag.add_element make_xml_element("title", post.title)
      post_tag.add_element make_xml_element("content", post.content)
      post_tag.add_element make_xml_element("location", post.location)
      post_tag.add_element make_xml_element("password", post.password)
      post_tag.add_element make_xml_element("acceptComment", (post.accept_comment == true ? 1 : 0))
      post_tag.add_element make_xml_element("acceptTrackback", (post.accept_trackback == true ? 1 : 0))
      post_tag.add_element make_xml_element("published", post.publish_date)
      post_tag.add_element make_xml_element("created", post.create_date)
      post_tag.add_element make_xml_element("modified", post.modify_date)
      post_tag.add_element make_xml_element("category", post.category)
      
      post.tags.each do |tag|
        post_tag.add_element make_xml_element("tag", tag)
      end
      
      post.comments.each do |comment|
        comment_tag = Element.new "comment"
        
        commenter_tag = Element.new "commenter"
        commenter_tag.add_attribute "id"
        commenter_tag.add_attribute "email"
        commenter_tag.attributes["email"] = comment.email
        
        commenter_tag.add_element make_xml_element("name", comment.name)
        commenter_tag.add_element make_xml_element("homepage", comment.homepage)
        commenter_tag.add_element make_xml_element("ip", comment.ip)
        
        comment_tag.add_element commenter_tag
        
        comment_tag.add_element make_xml_element("content", comment.content)
        comment_tag.add_element make_xml_element("password", comment.password)
        comment_tag.add_element make_xml_element("secret", (comment.secret == true ? 1 : 0))
        comment_tag.add_element make_xml_element("written", comment.write_date)
        
        post_tag.add_element comment_tag
      end
      
      post.attachments.each do |attach|
      	attach_tag = Element.new "attachment"
      	attach_tag.add_attribute "size"
      	attach_tag.add_attribute "width"
      	attach_tag.add_attribute "height"
      	
      	attach_tag.attributes["size"] = attach.attach_size.to_s
      	
      	(nil == attach.width || attach.width <= 0) ? 
      		attach_tag.attributes["width"] = "0" : 
      		attach_tag.attributes["width"] = attach.width.to_s
    		  
      	(nil == attach.height || attach.height <= 0) ? 
      		attach_tag.attributes["height"] = "0" : 
      		attach_tag.attributes["height"] = attach.height.to_s
      	
      	attach_tag.add_element make_xml_element("name", attach.name)
      	attach_tag.add_element make_xml_element("label", attach.name)
      	attach_tag.add_element make_xml_element("enclosure", 0)
      	attach_tag.add_element make_xml_element("attached", attach.attached)
      	attach_tag.add_element make_xml_element("downloads", 0)
      	attach_tag.add_element make_xml_element("content", attach.content)
      	
      	post_tag.add_element attach_tag
      	
    	end

      blog_tag.add_element post_tag
    end

    return doc_tt
    
  end
  
end
