CiteProc::Variable.filters[:bibtex] = (Hash.new { |h, k| k }).merge(Hash[*%w{
  date      issued
  isbn      ISBN
  booktitle container-title
  journal   container-title
  series    collection-title
  address   publisher-place
  pages     page
  number    issue
  url       URL
  doi       DOI
}])