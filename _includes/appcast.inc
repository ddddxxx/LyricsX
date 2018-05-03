<?xml version="1.0" encoding="utf-8"?>
<rss version="2.0" xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle" xmlns:dc="http://purl.org/dc/elements/1.1/">
	<channel>
		<title>{{ site.github.project_title }}</title>
		<description>Most recent changes with links to updates.</description>
		<language>en</language>
		{% for release in site.github.releases %}
		{%- unless release.draft -%}
		{%- unless release.prerelease and page.release_only -%}
		<item>
			<title>{{ release.name }}</title>
			<description><![CDATA[{{ release.body | markdownify }}]]></description>
			<pubDate>{{ release.published_at | date_to_rfc822 }}</pubDate>
			{%- assign asset = release.assets.first -%}
			{%- assign build_nums = asset.name | remove_first:site.github.project_title | remove_first:'_' | replace_first:'+',',' | remove_first:'.zip' | split:',' -%}
			{%- if build_nums.size == 2 -%}
				{%- assign version = build_nums[1] -%}
				{%- assign short_version = release.tag_name | remove_first:'v' -%}
			{%- else -%}
				{% assign version = release.tag_name | remove_first:'v' %}
			{%- endif -%}
			<enclosure
				url="{{ asset.browser_download_url }}"
				sparkle:version="{{ version }}"
				{% if short_version %}sparkle:shortVersionString="{{ release.tag_name | remove_first:'v' }}"{% endif %}
				length="{{ asset.size }}"
				type="application/octet-stream"
			/>
		</item>
		{%- endunless -%}
		{%- endunless -%}
		{% endfor %}
	</channel>
</rss>
