# Jungtaek Lim(Heart)

require 'utils'
require 'wp_attachment'

# WPXML ������ �Ľ��ؼ� ī�װ�, ����Ʈ, ���, Ʈ���� ���� ������ �����ϴ� Ŭ����
# @categories : �Ľ̵� ī�װ� ����Ʈ // Array of WPCategory
# @posts : �Ľ̵� ����Ʈ ����Ʈ // Array of WPPost
# @attachments : �Ľ̵� ÷������ ����Ʈ // Array of WPAttachment
class WPBackupParser
  
  attr_reader :categories, :posts, :attachments

  # xml_document : WPXML �� ���� // Document
  def initialize(xml_document)
    @document = xml_document

    @categories = []
    @posts = []
    @attachments = []
  end

  # ������ �Ľ��� �����Ѵ�
  # �Ľ� ������ �̹� �����ڿ��� �޾��� �ִ�
  def parse
    return if @document == nil

    parse_category
    parse_post
    
  end

  private

  # ī�װ� �κ� �Ľ�
  def parse_category
    # Category Parsing & Store
    XPath.each(@document, "//wp:category") do |category|
      wp_category = WPCategory.new

      wp_category.name = category.elements["wp:cat_name"].text

      cat_parent = category.elements["wp:category_parent"].text

      if (cat_parent != nil && cat_parent != "")
        wp_category.parent = cat_parent
      else
        wp_category.parent = nil
      end

      @categories.push wp_category

    end
  end

    # ����Ʈ �κ� �Ľ�
  def parse_post
    XPath.each(@document, "//item") do |post|
      
      # post / page(�Ϲ� �� Ȥ�� ������)
	    if "attachment" != post.elements["wp:post_type"].text
				@posts.push( parse_post_detail(post) )
		  # ÷������
		  else
		  	@attachments.push( parse_attachment_detail(post) )
	  	end

    end
    
  end
  
  # ����Ʈ �� ���� �Ľ�
  # post_element : <item> ��ü
  def parse_post_detail(post_element)
  	wp_post = WPPost.new
  	
		wp_post.status = post_element.elements["wp:status"].text
		
		password_text = post_element.elements["wp:post_password"].text
		wp_post.password = password_text if nil != password_text && "" != password_text
		
		wp_post.title = post_element.elements["title"].text
		wp_post.link = post_element.elements["link"].text
		wp_post.pub_date = post_element.elements["pubDate"].text
		wp_post.writer = post_element.elements["dc:creator"].text
		
		XPath.each(post_element, "category[@domain='category' & @nicename]") do |category_tag|
		  wp_post.add_category(category_tag.text)
		end
		
		XPath.each(post_element, "category[@domain='tag' & @nicename]") do |tag_tag|
		wp_post.add_tag(tag_tag.text)
		end
		
		wp_post.content = post_element.elements["content:encoded"].text
		wp_post.post_id = post_element.elements["wp:post_id"].text
		wp_post.post_date = post_element.elements["wp:post_date"].text
		
		comm_stats = post_element.elements["wp:comment_status"].text
		
		if comm_stats == "open"
		  wp_post.comment_status = true
		else
		  wp_post.comment_status = false
		end
		
		ping_stats = post_element.elements["wp:ping_status"].text
		
		if ping_stats == "open"
		  wp_post.ping_status = true
		else
		  wp_post.ping_status = false
		end
		
		parse_comment(post_element, wp_post)
		
		return wp_post
  end
  
  # ÷������ �� ���� �Ľ�
  # post_element : <item> ��ü
  def parse_attachment_detail(post_element)
  	wp_attachment = WPAttachment.new
  	
  	url = post_element.elements["wp:attachment_url"].text
  	
  	file_name = url[url.rindex('/')+1..-1]
  	
  	wp_attachment.name = file_name.dclone
  	wp_attachment.attach_url = url
  	
  	file_name.upcase!
  	if file_name.index(/(\.JPG|\.GIF|\.PNG|\.PCX)/)
  		# �׸� �����̹Ƿ� �̸� �޾� �׸� ũ�⸦ �˾Ƶд�
  		begin
	  		width, height = get_image_size_from_content( get_url_content(url) )
	  		
	  		wp_attachment.width = width
	  		wp_attachment.height = height
			rescue OpenURI::HTTPError => httperr
				# �ϴ��� �ƹ��͵� ���� �ʴ´�... ���߿� ����ó���� ����
			end
		end
  	
  	wp_attachment.post_date = post_element.elements["wp:post_date"].text
  	
  	return wp_attachment
  end
 
  # ��� �κ� �Ľ�
  # post : ����Ʈ �κ��� �±� // Element
  # wp_post_obj : ��� ������ ����Ʈ ��ü // WPPost
  def parse_comment(post, wp_post_obj)
    # comments Parsing & Store
    XPath.each(post, "wp:comment") do |comment|
      wp_comment = WPComment.new

      approved = comment.elements["wp:comment_approved"].text

      # ���� : ����� ��۸� ������
      next unless approved == "1"     # "1": accepted

      wp_comment.id = comment.elements["wp:comment_id"].text
      wp_comment.author = comment.elements["wp:comment_author"].text
      wp_comment.email = comment.elements["wp:comment_author_email"].text
      wp_comment.url = comment.elements["wp:comment_author_url"].text
      wp_comment.ip = comment.elements["wp:comment_author_IP"].text
      wp_comment.content = comment.elements["wp:comment_content"].text
      wp_comment.write_date = comment.elements["wp:comment_date"].text

      wp_post_obj.add_comment(wp_comment)
    end
  end

end
