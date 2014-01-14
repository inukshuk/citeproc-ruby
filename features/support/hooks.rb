Before do
  @style_root, @locale_root = CSL::Style.root, CSL::Locale.root

  CSL::Style.root  = File.join(Fixtures::PATH, 'styles')
  CSL::Locale.root = File.join(Fixtures::PATH, 'locales')
end

After do
  CSL::Style.root, CSL::Locale.root = @style_root, @locale_root
end
