def what_was_that_one_with(those_actors)
  # Find the movies starring all `those_actors` (an array of actor names).
  # Show each movie's title and id.
  # Movie.select('movies.title, movies.id')
  #      .joins(:castings, :actors)
  #      .where('SELECT COUNT(*)
  #              FROM castings
  #              JOIN actors
  #              ON actors.id = castings.actor_id
  #              WHERE actors.name IN (?)
  #              GROUP BY movies_id', those_actors)
    Movie.select('movies.id, movies.title')
         .joins(:actors)
         .where('actors.name IN (?)', those_actors)
         .group('movies.id, movies.title')
         .having('COUNT(actors.id) = ?', those_actors.length)
         .distinct
end

def golden_age
  # Find the decade with the highest average movie score.
  Movie.select('yr / 10 * 10 AS decade')
       .group('decade')
       .order('AVG(score) DESC')
       .limit(1)
       .first.decade

#   <<-SQL
#   SELECT
#     yr
#   FROM
#     movies
#   ORDER BY
#     AVG(score)
#   SQL
end

def costars(name)
  # List the names of the actors that the named actor has ever
  # appeared with.
  # Hint: use a subquery
  Casting.joins(:actor)
         .where("movie_id IN
         (SELECT movie_id
           FROM castings
           JOIN actors ON actors.id = castings.actor_id
           WHERE actors.name = ?)", name)
         .where.not(actors: {name: name})
         .distinct
         .pluck("actors.name")
end

def actor_out_of_work
  # Find the number of actors in the database who have not appeared in a movie
  Actor.where('actors.id NOT IN (
         SELECT
           actor_id
         FROM
           castings
         )')
       .pluck('COUNT(*)').first
end

def starring(whazzername)
  result = "%"
  whazzername.each_char {|char| result+= char + "%"}

  # Find the movies with an actor who had a name like `whazzername`.
  # A name is like whazzername if the actor's name contains all of the
  # letters in whazzername, ignoring case, in order.
  Movie.select("movies.*")
       .joins(:actors)
       .where("actors.name ILIKE ?", result)
  # ex. "Sylvester Stallone" is like "sylvester" and "lester stone" but
  # not like "stallone sylvester" or "zylvester ztallone"

end

def longest_career
  # Find the 3 actors who had the longest careers
  # (the greatest time between first and last movie).
  # Order by actor names. Show each actor's id, name, and the length of
  # their career.
  Casting.select('actors.id, actors.name, (MAX(movies.yr) - MIN(movies.yr)) AS career')
         .joins(:actor, :movie)
         .group('actors.id')
         .order('career DESC')
         .limit(3)
         .order('actors.name')
end
