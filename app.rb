require 'sinatra'
require 'sinatra/cross_origin'
require 'sinatra/activerecord'
require './config/environments'
require './config/cors'
require './models/product'
require './models/user'
require './models/entry'
require './models/order'
require 'json'

before do
  content_type :json
end

# Gets users
get '/tienda/users' do
  User.all.to_json
end

# Gets a single user
get '/tienda/users/:id' do
  User.where(id: params['id']).first.to_json
end

# Creates a user
post '/tienda/users' do
  user = User.new(name: params['name'])

  if user.save
    user.to_json
  else
    halt 422, user.errors.full_messages.to_json
  end

end

# Updates a user
put '/tienda/users/:id' do
  user = User.where(id: params['id'])

  if user
    user.name = params['name'] if params.has_key?('name')
    if user.save
      user.to_json
    else
      halt 422, user.errors.full_messages.to_json
    end
  end

end

# Deletes a user
delete '/tienda/users/:id' do
  user = User.where(id: params['id'])
  
  if user.destroy_all
    user.to_json
  else
    halt 500
  end

end

# Gets products
get '/tienda/products' do
  Product.all.to_json
end

# Gets a single product
get '/tienda/products/:id' do
  Product.where(id: params['id']).first.to_json
end

# Creates a product
post '/tienda/products' do
  product = Product.new(name: params['name'], price: params['price'].to_f)

  if product.save
    product.to_json
  else
    halt 422, product.errors.full_messages.to_json
  end

end

# Updates a product
put '/tienda/products/:id' do
  product = Product.where(id: params['id']).first

  if product
    product.name = params['name'] if params.has_key?('name')
    product.price = params['price'].to_f if params.has_key?('price')

    if product.save
      product.to_json
    else
      halt 422, product.errors.full_messages.to_json
    end

  end

end

# Deletes a product
delete '/tienda/products/:id' do
  product = Product.where(id: params['id'])

  if product.destroy_all
    product.to_json
  else
    halt 500
  end

end

# Gets user orders
get '/tienda/users/:user/orders' do
  Order.where(user_id: params['user']).all.to_json(except: :user_id)
end

# Gets single order with entries
get '/tienda/users/:user/orders/:id' do
  Order.where(user_id: params['user'],
              id: params['id']).first.to_json(
              include:
                   { entries:
                         { include: { product: { except: :id } },
                           except: [:product_id, :order_id, :id] }
                   },
              except: :user_id)
end

# Deletes order
delete '/tienda/users/:user/orders/:id' do
  order = Order.where(id: params['id'])

  if order.destroy_all
    order.to_json
  else
    halt 500
  end
end

# Gets products from an order
get '/tienda/users/:user/orders/:order/products' do
  Order.find_by(id: params['order'], user_id: params['user']).products.all.to_json
end

# Creates an order
post '/tienda/users/:user/orders' do
  order = Order.new(user_id: params['user'], total: 0.0, iva: 0.0, sub_total: 0.0)

  if order.save
    order.to_json
  else
    halt 422, order.errors.full_messages.to_json
  end

end

# Adds a product to an order
post '/tienda/users/:user/orders/:order/add/:qty/:product' do
  import = Product.where(id: params['product']).first.price*params['qty'].to_f
  if Order.where('id = ? AND user_id = ?', params['order'], params['user']).first
    entry = Entry.new(order_id: params['order'].to_i,
                      product_id: params['product'].to_i,
                      qty: params['qty'].to_i,
                      import: import)

    if entry.save
      order = Order.where(id: params['order']).first
      order.sub_total += import
      order.iva = order.sub_total*0.16
      order.total = order.sub_total+order.iva

      if order.save
        order.to_json(
          include:
              { entries:
                    { include: { product: { except: :id } },
                      except: [:product_id, :order_id, :id] }
              },
          except: :user_id)
      else
        halt 500
      end
    else
      halt 422, entry.errors.full_messages.to_json
    end
  else
    halt 422, 'El usuario no contiene ese pedido'
  end
end

# Deletes product from order
delete '/tienda/users/:user/orders/:order/delete/:product' do
  entry = Entry.where('order_id = ? AND product_id = ?', params['order'], params['product']).first

  if Order.where('id = ? AND user_id = ?', params['order'], params['user']).first
    if entry.destroy
      order = Order.where(id: params['order']).first
      order.sub_total -= entry.import
      order.iva = order.sub_total*0.16
      order.total = order.sub_total+order.iva

      if order.save
        order.to_json(
                    include:
                        { entries:
                              { include: { product: { except: :id } },
                                except: [:product_id, :order_id, :id] }
                        },
                    except: :user_id)
      else
        halt 500
      end
    else
      halt 500
    end
  else
    halt 422, 'El usuario no contiene ese pedido'
  end

end

# Get products from an order
get '/tienda/:user/orders/:id/products' do
  Order.where(id: params['id']).products.all.to_json
end