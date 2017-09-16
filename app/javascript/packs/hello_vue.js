/* eslint no-console: 0 */
// Run this example by adding <%= javascript_pack_tag 'hello_vue' %> (and
// <%= stylesheet_pack_tag 'hello_vue' %> if you set extractStyles to true
// in config/webpack/loaders/vue.js) to the head of your layout file,
// like app/views/layouts/application.html.erb.
// All it does is render <div>Hello Vue</div> at the bottom of the page.

import Vue from 'vue/dist/vue.esm'
import TurbolinksAdapter from 'vue-turbolinks'
import VueResource from 'vue-resource'

Vue.use(VueResource)

document.addEventListener('turbolinks:load', () => {
	Vue.http.headers.common['X-CSRF-Token'] = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
	var newsletterObject = {
		subject: '',
		content: '',
	}
	var app = new Vue({
		el: "#newsletters",
		data: {
			newsletters: [],
			newsletter: Object.assign({}, newsletterObject),
			editingCache: {
				subject: '',
				content: ''
			},
			editingKey: -1,
			errors: {},
			addNewsletter: false
		},
		created: function() {
			var that = this;
			this.$http.get('/newsletters.json').then(
				response => {
					that.newsletters = response.body.map(function(v) {
						v.message = ''
						return v
					})
				}, response => {
					that.errors = response.data.errors
				})
		},
		methods: {
			// Create a new Newsletter
			saveNewsletter: function() {
				var that = this
				this.$http.post('/newsletters', {
					newsletter: this.newsletter
				}).then(response => {
					that.errors = {}
					that.newsletter = Object.assign({}, newsletterObject)
					that.newsletters.push(response.data)
					that.editingKey = -1
					that.addNewsletter = false
				}, response => {
					that.errors = JSON.parse(response.bodyText)
				})
			},
			cancelCreateNewsletter: function() {
				this.newsletter = Object.assign({}, newsletterObject)
				this.addNewsletter = false
				this.errors = {}
			},
			// Edit an existing Newsletter
			editNewsletter: function(key) {
				this.editingKey = key
				this.editingCache = Object.assign({}, this.newsletters[key])
			},
			// update Edited Newsletter
			updateNewsletter: function(key) {
				var that = this
				this.$http.put(`/newsletters/${this.editingCache.id}`, {
					newsletter: this.editingCache
				}).then(response => {
					that.errors = {}
					that.newsletters[key] = this.editingCache
					that.editingKey = -1
				}, response => {
					that.errors = JSON.parse(response.bodyText)
				})
			},
			// destroy Newletter
			destroyNewsletter: function(newsletter) {
				var that = this
				this.$http.delete(`/newsletters/${newsletter.id}`, {
					newsletter: newsletter
				}).then(response => {
					that.errors = {}
					this.newsletters.splice(this.newsletters.indexOf(newsletter), 1);
				}, response => {
					that.errors = JSON.parse(response.bodyText)
				})
			},
			// Send Email with Mailgun
			sendWithMailgun: function(newsletter) {
				var that = this
				this.$http.post(`/newsletters/${newsletter.id}/sendWithMailgun`, {
					newsletter: newsletter
				}).then(response => {
					that.checkEmailResponse(response, "Mailgun", newsletter)
				}, response => {
					that.errors = JSON.parse(response.bodyText)
				})
			},
			sendWithSendgrid: function(newsletter) {
				var that = this
				this.$http.post(`/newsletters/${newsletter.id}/sendWithSendgrid`, {
					newsletter: newsletter
				}).then(response => {
					that.checkEmailResponse(response, "Sendgrid", newsletter)
				}, response => {
					that.errors = JSON.parse(response.bodyText)
				})
			},
			checkEmailResponse: function(response, service, newsletter) {
				var mailResponseCode = (response.body.table) ? (response.body.table.code) : 200
				if (mailResponseCode === 200) {
					newsletter.message = "Success Send Email with " + service
				} else {
					newsletter.message = response.body.table.message
				}
			}

		}

	})

})
