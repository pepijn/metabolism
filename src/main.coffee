window.enzymes = {}
window.molecules = []

template =
  enzyme: $('.enzyme')
  molecule: $('.molecule')

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
  'Triose phosphate isomerase':
    substrates: ['Dihydroxyacetone phosphate']
    products:   ['Glyceraldehyde 3-phosphate']
  'Glyceraldehyde-3-phosphate dehydrogenase':
    substrates: ['Glyceraldehyde 3-phosphate', 'Pi', 'NAD+']
    products:   ['1,3-bisphosphate glycerate', 'NADH']
  'Phosphoglycerate kinase':
    substrates: ['1,3-bisphosphate glycerate', 'ADP']
    products:   ['3-phosphoglycerate', 'ATP']
  'Phosphoglycerate mutase':
    substrates: '3-phosphoglycerate'
    products:   '2-phosphoglycerate'
  'Enolase':
    substrates: '2-phosphoglycerate'
    products:   ['H2O', 'Phosphoenolpyruvate']
  'Pyruvate kinase':
    substrates: ['Phosphoenolpyruvate', 'ADP']
    products:   ['Pyruvate', 'ATP']

molecule = (element) ->
  element.text().replace(/^\s+|\s+$/g, '')
#
# molecule = (element) ->
#   window.molecules[element.attr('id').replace('molecule-', '')]

class Unit
  constructor: ->
    @id = @name.toLowerCase().replace(' ', '-')

  build: (template) ->
    @element = template.clone().attr('id', @id).text(@name)
    @element.appendTo(cytoplasm)

class Enzyme extends Unit
  constructor: (@name, substrates, products) ->
    super()
    @substrates = _.flatten [substrates]
    @products   = _.flatten [products]
    @bindings   = []

  accepts: (substrate) ->
    _.include(_.difference(@substrates, @molecules()), molecule(substrate))

  bind: (molecule) ->
    if @accepts(molecule)
      @bindings.push molecule
      molecule.draggable('disable')

      @element.addClass('occupied')

      # Probeer de reactie
      @react()

  molecules: ->
    _.map(@bindings, (element) -> molecule(element))

  react: ->
    if @bindings.length == @substrates.length
      for product in @products
        binding = if _i >= @bindings.length then @bindings[0] else @bindings[_i]
        product = binding.clone().appendTo(binding.parent()).text(product)

        $('.molecule').removeClass('ui-draggable-disabled').draggable()
        product.effect('highlight')

      for binding in @bindings
        binding.hide('puff')
      @bindings = []

      @element.effect('highlight')
      @element.removeClass('occupied')



for name of list
  enzyme = list[name]
  enzyme = new Enzyme name, enzyme.substrates, enzyme.products
  window.enzymes[enzyme.id] = enzyme

  enzyme.build(template.enzyme).droppable({
      accept: ".molecule",
      hoverClass: "hover",
      activate: (event, ui) ->
        enzyme = enzymes[$(this).attr('id')]

        $(this).addClass('active') if enzyme.accepts(ui.draggable)
      deactivate: ->
        $(this).removeClass('active')

      drop: (event, ui) ->
        enzyme = enzymes[$(this).attr('id')]
        enzyme.bind(ui.draggable)
  	})

$('.molecule').draggable()
