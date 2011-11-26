window.enzymes = {}

template =
  enzyme: $('#templates .enzyme')
  molecule: $('#templates .molecule')

cell =
  cytoplasm: $('#cytoplasm')

list =
  'Hexokinase':
    substrates: ['Glucose', 'ATP']
    products:   ['Glucose 6-phosphate', 'ADP']
  'Phosphoglucose isomerase':
    substrates: 'Glucose 6-phosphate'
    products:   'Fructose 6-phosphate'
  'Phosphofructokinase-1':
    substrates: ['Fructose 6-phosphate', 'ATP']
    products:   ['Fructose 1,6-biphosphate', 'ADP']
  'Aldolase':
    substrates: 'Fructose 1,6-biphosphate'
    products:   ['Dihydroxyacetone phosphate', 'Glyceraldehyde 3-phosphate']
  'Triose phosphate isomerase': [
      substrates: ['Dihydroxyacetone phosphate']
      products:   ['Glyceraldehyde 3-phosphate']
    ,
      substrates: ['Glyceraldehyde 3-phosphate']
      products:   ['Dihydroxyacetone phosphate']
    ]
  'Glyceraldehyde-3-phosphate dehydrogenase':
    substrates: ['Glyceraldehyde 3-phosphate', 'NAD+', 'Pi']
    products:   ['1,3-bisphosphate glycerate', 'NADH']
  'Phosphoglycerate kinase':
    substrates: ['1,3-bisphosphate glycerate', 'ADP']
    products:   ['3-phosphoglycerate', 'ATP']
  'Phosphoglycerate mutase':
    substrates: '3-phosphoglycerate'
    products:   '2-phosphoglycerate'
  'Enolase':
    substrates: '2-phosphoglycerate'
    products:   ['Water', 'Phosphoenolpyruvate']
  'Pyruvate kinase':
    substrates: ['Phosphoenolpyruvate', 'ADP']
    products:   ['Pyruvate', 'ATP']
  'Pyruvate dehydrogenase':
    substrates: ['CoA-SH', 'NAD+', 'Pyruvate']
    products:   ['CO2', 'NADH', 'acetyl-CoA']
  'Citrate synthase':
    substrates: ['acetyl-CoA', 'Oxaloacetate', 'Water']
    products:   ['CoA-SH', 'Citrate']
  'Aconitase': [
      substrates: 'Citrate'
      products:   ['cis-Aconitate', 'Water']
    ,
      substrates: ['cis-Aconitate', 'Water']
      products:   ['Isocitrate']
    ]
  'Isocitrate dehydrogenase': [
      substrates: ['Isocitrate', 'NAD+']
      products:   ['Oxalosuccinate', 'NADH', 'H+']
    ,
      substrates: 'Oxalosuccinate'
      products:   ['alpha-Ketoglutarate', 'CO2']
    ]
  'alpha-Ketoglutarate dehydrogenase':
    substrates: ['alpha-Ketoglutarate', 'NAD+', 'CoA-SH']
    products:   ['Succinyl-CoA', 'NADH', 'H+', 'CO2']
  'Succinyl-CoA synthetase':
    substrates: ['Succinyl-CoA', 'GDP', 'Pi']
    products:   ['Succinate', 'CoA-SH', 'GTP']
  'Succinate dehydrogenase':
    substrates: ['Succinate', 'Ubiquinone']
    products:   ['Fumarate', 'Ubiquinol']
  'Fumarase':
    substrates: ['Fumarate', 'Water']
    products:   'Malate'
  'Malate dehydrogenase':
    substrates: ['Malate', 'NAD+']
    products:   ['Oxaloacetate', 'NADH', 'H+']

convert = (string) ->
  string.toLowerCase().replace /\s|[+]/gi, '-'

# molecule = (element) ->
#   window.molecules[element.attr('id').replace('molecule-', '')]

add_molecule = (substrate, name) ->
  molecule = substrate.clone().text(name)

  container = $('#' + convert name)
  if container.length == 0
    container = $('#various')
  else
    pos = container.offset()
    molecule.animate({ top: pos.top, left: pos.left }, 1000)

  container.append(molecule)
  container_count(container)

  molecule.removeClass('ui-draggable-disabled').effect('highlight').draggable({
    tolerance: 'touch',
    revert: 'invalid',
    start: -> $('.enzyme').droppable('enable')
  })

container_count = (container) ->
  container.find('p').text container.children().size() - 1

for molecule in ["Glucose", "ATP", "ATP", "NAD+", "NAD+", "Pi", "Pi", "ADP", "ADP", "CoA-SH", "NAD+", "Oxaloacetate", "Water", "Ubiquinone", "GDP", "Pi", "Water", "NAD+", "NAD+", "NAD+"]
  add_molecule(template.molecule, molecule)

class Unit
  constructor: ->
    @id = convert @name

  build: (template) ->
    @element = template.clone().attr('id', @id).text(@name)
    @element.appendTo(cytoplasm)

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

  accepts: (substrate) ->
    _.include(_.difference(@substrates(), @molecules()), substrate.text())

  bind: (molecule) ->
    if @accepts(molecule)
      @bindings.push molecule
      molecule.draggable('disable')
      @element.addClass('occupied')

      # Probeer de reactie
      @react()

  molecules: ->
    _.map(@bindings, (element) -> element.text())

  react: ->
    if @bindings.length == @substrates().length
      for product in @reaction()[0].products
        binding = if _i >= @bindings.length then @bindings[0] else @bindings[_i]

        add_molecule(binding, product)

      for binding in @bindings
        binding.hide('puff', {}, 100, ->
          container = $(this).parent()
          $(this).remove()
          container_count(container)
        )
      @bindings = []

      @element.effect('highlight')
      @element.removeClass('occupied')

for name of list
  reactions = list[name]
  enzyme = new Enzyme name, reactions
  window.enzymes[enzyme.id] = enzyme

  enzyme.build(template.enzyme).droppable({
      accept: ".molecule",
      hoverClass: "hover",
      activate: (event, ui) ->
        enzyme = enzymes[$(this).attr('id')]
        if enzyme.accepts(ui.draggable)
          $(this).addClass('active')
        else
          $(this).droppable('disable')
      deactivate: ->
        $(this).removeClass('active')
      drop: (event, ui) ->
        enzyme = enzymes[$(this).attr('id')]
        enzyme.bind(ui.draggable)
  	})

# if false
  # $('.molecule').draggable({ snap: '.enzyme', snapMode: 'inner' })
# else
  # $('.enzyme').draggable({ grid: [20, 10] })

window.positions = ->
  log = ''

  $('#cell .enzyme').each((index, element)->
    el = $(element)
    offset = el.offset()
    log += '#' + el.attr('id') + ' {'
    log += '  top: ' + offset.top + 'px;'
    log += '  left: ' + offset.left + 'px;'
    log += '} '
  )

  console.log log
