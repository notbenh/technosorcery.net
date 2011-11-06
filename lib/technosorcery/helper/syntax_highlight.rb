module Technosorcery
  module Helper
    module SyntaxHighlight
      require 'cgi'

      def highlight(lang, code)
        <<-HERE
<pre><code class="language-#{lang}">
#{escape_code(code, false)}
</code></pre>
HERE
      end

      def escape_code(code, code_tags=true)
        ret = CGI.escapeHTML(code)

        if code_tags
          "<code>#{ret}</code>"
        else
          ret
        end
      end
    end
  end
end
