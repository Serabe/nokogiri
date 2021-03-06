module Nokogiri
  if RUBY_PLATFORM !~ /java/ && self.is_2_6_16? && !defined?(I_KNOW_I_AM_USING_AN_OLD_AND_BUGGY_VERSION_OF_LIBXML2)
    warn <<-eom
HI.  You're using libxml2 version 2.6.16 which is over 4 years old and has
plenty of bugs.  We suggest that for maximum HTML/XML parsing pleasure, you
upgrade your version of libxml2 and re-install nokogiri.  If you like using
libxml2 version 2.6.16, but don't like this warning, please define the constant
I_KNOW_I_AM_USING_AN_OLD_AND_BUGGY_VERSION_OF_LIBXML2 before requring nokogiri.
    eom
  end
end
