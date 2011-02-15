#--
# CiteProc-Ruby
# Copyright (C) 2009-2011 Sylvester Keil <sylvester.keil.or.at>
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.	If not, see <http://www.gnu.org/licenses/>.
#++

CSL::Item.converters[:bibtex] = (Hash.new { |hash, key| key.to_s }).merge(Hash[*%w{
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