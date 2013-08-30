'use strict'

angular.module('appApp.controllers')
  .controller('IndividualCtrl', ['$scope', 'ApiGet', ($scope, ApiGet) ->


######################
# Variable Setup
######################

    # these were defined in AppCtrl and $scope will delegate to $rootScope
      # $scope.reps
      # $scope.selected
      # $scope.reps_list

    # init local variables

######################
# Define API Methods
######################

    $scope.get_transparencydata_id = (bioguide_id)->
      $scope.reps[bioguide_id] = $scope.reps[bioguide_id] or {}
      if not $scope.reps[bioguide_id].influence
        ApiGet.influence "entities/id_lookup.json?bioguide_id=#{bioguide_id}&", $scope.callback_transparencydata_id, this, bioguide_id
        $scope.rep = $scope.reps[$scope.selected.rep1.bioguide_id]

    $scope.callback_transparencydata_id = (error, data, bioguide_id)->
      if not error
        $scope.reps[bioguide_id].influence = $scope.reps[bioguide_id].influence or {}
        $scope.reps[bioguide_id].influence.id = data.id
        ## Call dependents of influence id
        $scope.get_bio(data.id, bioguide_id)
      else console.log "Error: ", error

    $scope.get_bio = (transparencydata_id, bioguide_id)->
      if not $scope.reps[bioguide_id].influence.bio
        ApiGet.influence "entities/#{transparencydata_id}.json?", $scope.callback_bio, this, bioguide_id

    $scope.callback_bio = (error, data, bioguide_id)->
      if not error
        $scope.reps[bioguide_id].influence.bio = data
      else console.log "Error: ", error

    $scope.callback_nyt = (error, data, bioguide_id)->
      if not error
        $scope.reps[bioguide_id].nyt = $scope.reps[bioguide_id].nyt or {}
        $scope.reps[bioguide_id].nyt.overview = data
      else console.log "Error: ", error

    $scope.callback_littleSis_id = (error, data, bioguide_id)->
      if not error
        $scope.reps[bioguide_id].littleSis = $scope.reps[bioguide_id].littleSis or {}
        console.log(data)
        $scope.reps[bioguide_id].littleSis.id = data.Response.Data.Entities.Entity.id
        $scope.reps[bioguide_id].littleSis.overview = data.Response.Data.Entities.Entity
        #Call dependent on id
        ApiGet.littleSis "entity/#{$scope.reps[bioguide_id].littleSis.id}/related.json?cat_ids=5&", $scope.callback_littleSisDonors, this, bioguide_id
      else console.log "Error: ", $error

    $scope.callback_littleSisDonors = (error, data, bioguide_id)->
      match = []
      console.log(data)

      if not error
        _.each data.Response.Data.RelatedEntities.Entity, (val) ->
          if val.Relationships.Relationship.amount
            if val.Relationships.Relationship.amount >= 15000
              match.push
                name: val.name
                summary: val.summary
                amount: val.Relationships.Relationship.amount

          else if val.Relationships.Relationship[0]
            _.each val.Relationships.Relationship, (subVal) ->
              if subVal.amount >= 15000
                match.push
                  name: val.name
                  summary: val.summary
                  amount: subVal.amount

        sorted =  _.sortBy(match, (val)-> val.amount*-1).splice(0,10)
        $scope.reps[bioguide_id].littleSis.donors = sorted
      else console.log "Error: ", error


##############
## Initial Calls
##############

    $scope.get_transparencydata_id($scope.selected.rep1.bioguide_id)
    ApiGet.littleSis "entities/bioguide_id/#{$scope.selected.rep1.bioguide_id}.json?", $scope.callback_littleSis_id, this, $scope.selected.rep1.bioguide_id
    ApiGet.nyt "members/#{$scope.selected.rep1.bioguide_id}", $scope.callback_nyt, this, $scope.selected.rep1.bioguide_id

  ])
