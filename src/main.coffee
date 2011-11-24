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

elname = (element) ->
  element.text().replace(/^\s+|\s+$/g, '')

molecule = (element) ->
  window.molecules[element.attr('id').replace('molecule-', '')]

class Unit
  constructor: ->
    @id = @name.toLowerCase().replace(' ', '-')

  build: (template) ->
    template.clone().attr('id', @id).text(@name).appendTo(cytoplasm)

class Enzyme extends Unit
  constructor: (@name, substrates, products) ->
    super()
    @substrates = _.flatten [substrates]
    @products   = _.flatten [products]
    @bindings = []

  accepts: (substrate) ->
    true if _.include(_.difference(@substrates, @molecules()), substrate.name)

  bind: (molecule) ->
    if @accepts(molecule)
      molecule.bind()
      @bindings.push molecule

      # Probeer de reactie
      @react()

  molecules: ->
    _.map(@bindings, (molecule) -> molecule.name)

  react: ->
    if @bindings.length == @substrates.length
      @bindings.push @bindings[0].clone() #if @bindings.length < @products.length

      for molecule in @bindings
        index = _.indexOf(@substrates, molecule.name)
        product = @products[index]

        molecule.release(product)

      # @bindings = []


class Molecule extends Unit
  constructor: (@name) ->
    number = window.molecules.length
    window.molecules.push this
    @id = 'molecule-' + number
    @element = @build(template.molecule)

  bind: ->
    @element.draggable('disable')

  release: (name) ->
    @name = name
    @element.text(@name)
    @element.effect('highlight')
    @element.draggable('enable')

for name of list
  enzyme = list[name]
  enzyme = new Enzyme name, enzyme.substrates, enzyme.products
  window.enzymes[enzyme.id] = enzyme

  enzyme.build(template.enzyme).droppable({
      accept: ".molecule",
      hoverClass: "hover",
      activate: (event, ui) ->
        enzyme = enzymes[$(this).attr('id')]

        $(this).addClass('active') if enzyme.accepts(molecule(ui.draggable))
      deactivate: ->
        $(this).removeClass('active')

      drop: (event, ui) ->
        enzyme = enzymes[$(this).attr('id')]
        enzyme.bind(molecule(ui.draggable))
  	})

new Molecule "Glucose"
new Molecule "ATP"
new Molecule "Fructose 1,6-biphosphate"
new Molecule "ATP"

$('.molecule').draggable()
