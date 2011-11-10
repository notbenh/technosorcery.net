# All files in the 'lib' directory will be loaded
# before nanoc starts compiling.

require 'technosorcery/helper/syntax_highlight'

include Nanoc3::Helpers::Blogging
include Nanoc3::Helpers::LinkTo
include Nanoc3::Helpers::Rendering
include Nanoc3::Helpers::Tagging
include Technosorcery::Helper::SyntaxHighlight

require 'set'
require 'time'
require 'uri'

MONTHS = {
  1 => "January",  5 => "May",     9 => "September",
  2 => "February", 6 => "June",   10 => "October",
  3 => "March",    7 => "July",   11 => "November",
  4 => "April",    8 => "August", 12 => "December"
}

def uri_escape(uri)
  URI.escape(uri)
end

def create_item (identifier, metadata)
  content = metadata.has_key?(:content) ? metadata.delete(:content) : ""
  @site.items << Nanoc3::Item.new(content, metadata, identifier)
end

def canonicalize_created_at
  @items.each do |i|
    ctime = i[:created_at]
    i[:created_at] = Time.parse(ctime) if ctime.is_a?(String)
  end
end

def sort_articles_by_created_at(article_list)
  article_list.sort do |b,a|
    a[:created_at] <=> b[:created_at]
  end
end

def articles_for_year(year)
  sorted_articles.select do |i|
    i[:created_at].year == year
  end
end

def articles_for_month(year, month)
  sorted_articles.select do |i|
    cdate = i[:created_at]
    cdate.year == year && cdate.month == month
  end
end

def each_tag(&blk)
  tags = Set.new
  articles.each do |a|
    (a[:tags] || []).each do |tag|
      tags.add(tag)
    end
  end

  tags.sort {|a,b| a.downcase <=> b.downcase}.each do |t|
    yield t
  end
end

def each_year(&blk)
  articles_by_year = {}
  articles.each do |a|
    articles_by_year[a[:created_at].year] ||= []
    articles_by_year[a[:created_at].year] << a
  end

  articles_by_year.keys.sort.each do |k|
    yield k, sort_articles_by_created_at(articles_by_year[k])
  end
end

def each_month(year, year_articles, &blk)
  articles_by_month = {}
  year_articles.each do |a|
    articles_by_month[a[:created_at].month] ||= []
    articles_by_month[a[:created_at].month] << a
  end

  articles_by_month.keys.sort.each do |k|
    yield k, year, articles_by_month[k]
  end
end

def generate_summary_pages
  each_tag do |t|
    create_tag_item(t)
  end
  each_year do |year,year_articles|
    create_item(
      "/#{year}/",
      :year          => year,
      :year_articles => year_articles,
      :layout        => "year_page",
      :title         => "Posts from #{year}"
    )
    each_month(year, year_articles) do |month,year,month_articles|
      create_item(
        "/#{year}/#{month}/",
        :year           => year,
        :month          => month,
        :month_articles => month_articles,
        :layout         => "month_page",
        :title          => "Posts from #{MONTHS[month]} #{year}"
      )
    end
  end
end

def create_tag_item(tag)
  create_item(
    "/tag/#{tag}/",
    :tag    => tag,
    :layout => "tag_page",
    :title  => "Posts tagged #{tag}"
  )
end
