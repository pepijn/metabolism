window.enzymes = {}

template =
  enzyme: $('#templates .enzyme')
  molecule: $('#templates .molecule')

cell =
  'cytosol': $('#cytosol')
  'intermembrane space': $('#intermembrane-space')
  'mitochondrial matrix': $('#mitochondrial-matrix')

compartments =
  "cytosol":
    "Hexokinase":
      "substrates": ["Glucose", "ATP"]
      "products":   ["Glucose 6-phosphate", "ADP"]
    "Phosphoglucose isomerase":
      "substrates": "Glucose 6-phosphate"
      "products":   "Fructose 6-phosphate"
    "Phosphofructokinase-1":
      "substrates": ["Fructose 6-phosphate", "ATP"]
      "products":   ["Fructose 1,6-biphosphate", "ADP"]
    "Aldolase":
      "substrates": "Fructose 1,6-biphosphate"
      "products":   ["Dihydroxyacetone phosphate", "Glyceraldehyde 3-phosphate"]
    "Triose phosphate isomerase": [
        "substrates": ["Dihydroxyacetone phosphate"]
        "products":   ["Glyceraldehyde 3-phosphate"]
      ,
        "substrates": ["Glyceraldehyde 3-phosphate"]
        "products":   ["Dihydroxyacetone phosphate"]
      ]
    "Glyceraldehyde-3-phosphate dehydrogenase":
      "substrates": ["Glyceraldehyde 3-phosphate", "NAD+", "Pi"]
      "products":   ["1,3-bisphosphate glycerate", "NADH"]
    "Phosphoglycerate kinase":
      "substrates": ["1,3-bisphosphate glycerate", "ADP"]
      "products":   ["3-phosphoglycerate", "ATP"]
    "Phosphoglycerate mutase":
      "substrates": "3-phosphoglycerate"
      "products":   "2-phosphoglycerate"
    "Enolase":
      "substrates": "2-phosphoglycerate"
      "products":   ["Water", "Phosphoenolpyruvate"]
    "Pyruvate kinase":
      "substrates": ["Phosphoenolpyruvate", "ADP"]
      "products":   ["Pyruvate", "ATP"]
      # "transport":  "mitochondrial matrix"
    "Pyruvate transport":
      "substrates": "ATP"
      "products":   ["ADP", "Pi"]
      "transport":
        "substrates":  "Pyruvate"
        "destination": "mitochondrial matrix"
    "NADH transport":
      "substrates": "ATP"
      "products":   ["ADP", "Pi"]
      "transport":
        "substrates":  "NADH"
        "destination": "mitochondrial matrix"
  "intermembrane space":
    "ATP synthase":
      "substrates": ["ADP", "Pi"]
      "products":   "ATP"
      "transport":
        "substrates":  ["H+", "H+", "H+"]
        "destination": "mitochondrial matrix"
    "ATP/ADP Translocase":
      "substrates": ["ADP", "ATP"]
      "products":   ["ATP", "ADP"]
  "mitochondrial matrix":
    "Pyruvate dehydrogenase":
      "substrates": ["CoA-SH", "NAD+", "Pyruvate"]
      "products":   ["CO2", "NADH", "acetyl-CoA", "H+"]
    "Citrate synthase":
      "substrates": ["acetyl-CoA", "Oxaloacetate", "Water"]
      "products":   ["CoA-SH", "Citrate"]
    "Aconitase": [
        "substrates": "Citrate"
        "products":   ["cis-Aconitate", "Water"]
      ,
        "substrates": ["cis-Aconitate", "Water"]
        "products":   ["Isocitrate"]
      ]
    "Isocitrate dehydrogenase": [
        "substrates": ["Isocitrate", "NAD+"]
        "products":   ["Oxalosuccinate", "NADH", "H+"]
      ,
        "substrates": "Oxalosuccinate"
        "products":   ["alpha-Ketoglutarate", "CO2"]
      ]
    "alpha-Ketoglutarate dehydrogenase":
      "substrates": ["alpha-Ketoglutarate", "NAD+", "CoA-SH"]
      "products":   ["Succinyl-CoA", "NADH", "H+", "CO2"]
    "Succinyl-CoA synthetase":
      "substrates": ["Succinyl-CoA", "GDP", "Pi"]
      "products":   ["Succinate", "CoA-SH", "GTP"]
    "Succinate dehydrogenase":
      "substrates": ["Succinate", "Ubiquinone"]
      "products":   ["Fumarate", "Ubiquinol"]
    "Fumarase":
      "substrates": ["Fumarate", "Water"]
      "products":   "Malate"
    "Malate dehydrogenase":
      "substrates": ["Malate", "NAD+"]
      "products":   ["Oxaloacetate", "NADH", "H+"]
    "Complex I":
      "substrates": "NADH"
      "products":   ["NAD+", "H+"]
      "transport":
        "substrates":  ["H+", "H+", "H+", "H+"]
        "destination": "intermembrane space"
    "Complex III":
      "substrates": ["Ubiquinol", "Cyt c (ox)", "Cyt c (ox)"]
      "products":   ["Ubiquinone", "Cyt c (red)", "Cyt c (red)", "H+", "H+"]
      "transport":
        "substrates":  ["H+", "H+"]
        "destination": "intermembrane space"
    "Complex IV":
      "substrates": ["Cyt c (red)", "Cyt c (red)", "Cyt c (red)", "Cyt c (red)", "Oxygen", "H+", "H+", "H+", "H+"]
      "products":   ["Cyt c (ox)", "Cyt c (ox)", "Cyt c (ox)", "Cyt c (ox)", "Water", "Water"]
      "transport":
        "substrates":  ["H+", "H+", "H+", "H+"]
        "destination": "intermembrane space"

convert = (string) ->
  string.toLowerCase().replace /\s|[+/()]/gi, '-'

add_molecule = (substrate, name, transport) ->
  type     = convert name
  molecule = substrate.clone().text(name).attr('class', 'molecule ' + type)

  if transport
    pos = cell[transport].position()
    cell[transport].append molecule.animate({ top: pos.top, left: pos.left }, 500)
  else
    substrate.parent().append molecule

  compartment = molecule.closest('#cell > div')
  container = compartment.find('.container > .' + type)

  if container.length == 1
    pos = container.position()
    molecule.animate({ top: pos.top, left: pos.left }, 500)
    container.append(molecule)
    container_count()
  else
    compartment.append molecule

  molecule.effect('highlight').draggable({
    tolerance: 'touch',
    revert: 'invalid',
    containment: compartment,
    start: -> $('.enzyme').droppable('enable')
  })

container_count = ->
  for container in $('.container > div')
    container = $(container)
    container.find('p').text container.children().size() - 1 if container.length

initial_molecules =
  'cytosol':
    'Glucose': 1
    'ATP': 2
    'NAD+': 2
    'Pi': 2
    'Pyruvate': 1
  'intermembrane space':
    'H+': 10
    'Ubiquinone': 1
    # 'Ubiquinol': 1
    'Cyt c (ox)': 4
    # 'Cyt c (red)': 4
  'mitochondrial matrix':
    'H+': 10
    'CoA-SH': 1
    'Oxaloacetate': 1
    'GDP': 2
    'Oxygen': 2
    'Water': 3
    'Pi': 16
    'ADP': 11

for compartment, molecules of initial_molecules
  for type, amount of molecules
    add_molecule(template.molecule, type, compartment) for num in [1..amount]

class Unit
  constructor: ->
    @id = convert @name

  build: (template) ->
    @element = template.clone().attr('id', @id).text(@name)

class Enzyme extends Unit
  constructor: (@name, reactions) ->
    super()
    @reactions  = _.flatten [reactions]
    @bindings   = []

    for reaction in @reactions
      reaction.substrates = _.flatten [reaction.substrates]
      reaction.products   = _.flatten [reaction.products]

  # Welke reacties zijn er nog allemaal mogelijk?
  reaction: ->
    if @bindings.length
      reactions = []

      for reaction in @reactions
        if _.all(@molecules(), (mol) -> _.include reaction.substrates, mol)
          reactions.push reaction

      reactions
    else
      # Nog geen bindingen, alle reacties zijn mogelijk
      @reactions

  substrates: ->
    _.flatten _.map @reaction(), (reaction) -> reaction.substrates

  molecules: ->
    _.map(@bindings, (element) -> element.text())

  accepts: (substrate) ->
    missing_bonds = @substrates()

    for binding in @bindings
      missing_bonds.splice(_.indexOf(missing_bonds, binding.text()), 1)

    _.include(missing_bonds, substrate.text())

  bind: (molecule) ->
    if @accepts(molecule)
      @bindings.push molecule

      pos = @element.position()
      molecule.draggable('disable')
      @element.addClass('occupied')

      # Probeer de reactie
      @react()

  react: ->
    if @bindings.length == @substrates().length
      reaction = @reaction()[0]

      @bindings = _.sortBy @bindings, (molecule) -> molecule.text()

      for product, n in reaction.products
        binding = if n >= @bindings.length then @bindings[0] else @bindings[n]

        add_molecule(binding, product)

      # Transport
      if reaction.transport
        pos = @element.position()
        molecules  = @element.closest('#cell > div').find('.molecule')
        substrates = _.flatten [reaction.transport.substrates]
        products   = []

        for molecule in molecules
          if $(molecule).text() == _.last substrates
            products.push molecule
            substrates.pop()

        move = ->
          $(products.pop()).animate { top: pos.top, left: pos.left }, 600, ->
            molecule = $(this)
            add_molecule molecule, molecule.text(), reaction.transport.destination
            molecule.remove()
            container_count molecule
            move()

        move()

      for binding in @bindings
        binding.hide 'puff', {}, 100, ->
          container = $(this).parent()
          $(this).remove()
          container_count()
      @bindings = []

      @element.effect('highlight')
      @element.removeClass('occupied')

for compartment, enzymes of compartments
  for name, reactions of enzymes
    enzyme = new Enzyme name, reactions
    window.enzymes[enzyme.id] = enzyme

    cell[compartment].append enzyme.build(template.enzyme).droppable({
      accept: ".molecule",
      hoverClass: "hover",
      activate: (event, ui) ->
        enzyme = window.enzymes[$(this).attr('id')]
        if enzyme.accepts(ui.draggable)
          $(this).addClass('active')
        else
          $(this).droppable('disable')
      deactivate: ->
        $(this).removeClass('active')
      drop: (event, ui) ->
        enzyme = window.enzymes[$(this).attr('id')]
        enzyme.bind(ui.draggable)
    })


# $('.enzyme').draggable({ grid: [5, 10] })

window.positions = ->
  log = ''

  $('#cell .enzyme').each((index, element)->
    el = $(element)
    offset = el.offset()
    log += '#' + el.attr('id') + ' {'
    log += '  top: ' + (offset.top - 10) + 'px;'
    log += '  left: ' + (offset.left - 10) + 'px;'
    log += '} '
  )

  console.log log

atp_synthesis = ->
  matrix = cell['mitochondrial matrix']
  if cell['intermembrane space'].find('.molecule.h-').length - 3 >= matrix.find('.molecule.h-').length && matrix.find('.molecule.adp').length > 0
    for molecule in matrix.find('.molecule.adp:first, .molecule.pi:first')
      window.enzymes['atp-synthase'].bind $(molecule)

setInterval atp_synthesis, 2500

