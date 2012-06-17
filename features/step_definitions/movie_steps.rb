# Add a declarative step here for populating the DB with movies.

checked_ratings = Array.new
found_movies = Array.new

Given /the following movies exist/ do |movies_table|
  movies_table.hashes.each do |movie|
    Movie.create!(:title => movie[:title], :rating => movie[:rating], :release_date => movie[:release_date])
  end
end

# Make sure that one string (regexp) occurs before or after another one
#   on the same page

Then /I should see "(.*)" before "(.*)"/ do |e1, e2|
  #  ensure that that e1 occurs before e2.
  #  page.content  is the entire content of the page as a string.
  flunk "Unimplemented"
end

# Make it easier to express checking or unchecking several boxes at once
#  "When I uncheck the following ratings: PG, G, R"
#  "When I check the following ratings: G"

When /I (un)?check the following ratings: (.*)/ do |uncheck, rating_list|
  if uncheck.nil? || uncheck.blank?
    rating_list.split.each { |rating|
      checked_ratings << rating if !checked_ratings.include?(rating) && Movie.all_ratings.include?(rating) }
  else
    rating_list.split.each { |rating|
      checked_ratings.delete(rating) if checked_ratings.include?(rating) && Movie.all_ratings.include?(rating) }
  end
end

When /I submit the search form on the homepage/ do
  conditions = String.new
  checked_ratings.each do |rating|
    conditions.concat(' or ') if !conditions.empty?
    conditions.concat("rating == '#{rating}'")
  end
  found_movies = Movie.find(:all, :conditions => [conditions])
end

When /I sort by Movie Title/ do
  found_movies = Movie.all.sort { |movie1, movie2| movie1.title <=> movie2.title }
end

When /I sort by Release Date/ do
  found_movies = Movie.all.sort { |movie1, movie2| movie1.release_date <=> movie2.release_date }
end

Then /I will (not )?see movies with the following ratings: (.*)/ do |not_added, rating_list|
  if not_added.nil? || not_added.blank?
    return_value = true
    found_movies.each { |movie| return_value = false if !rating_list.split.include?(movie.rating) }
    return_value
  else
    return_value = true
    found_movies.each { |movie| return_value = false if rating_list.split.include?(movie.rating) }
    return_value
  end
end

Then /I will see no movies/ do
  found_movies.count == 0
end

Then /I will see all movies/ do
  found_movies == Movie.all
end

Then /I will see (.*) before (.*)/ do |title1, title2|
  movie1 = Movie.find_by_title(title1)
  movie2 = Movie.find_by_title(title2)
  found_movies.index(movie1) < found_movies.index(movie2)
end
