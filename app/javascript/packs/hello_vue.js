/* eslint no-console: 0 */
// Run this example by adding <%= javascript_pack_tag 'hello_vue' %> (and
// <%= stylesheet_pack_tag 'hello_vue' %> if you set extractStyles to true
// in config/webpack/loaders/vue.js) to the head of your layout file,
// like app/views/layouts/application.html.erb.
// All it does is render <div>Hello Vue</div> at the bottom of the page.

import Vue from 'vue/dist/vue.esm'
import TurbolinksAdapter from 'vue-turbolinks'
import VueResource from 'vue-resource'
import InputTag from 'vue-input-tag'

Vue.use(VueResource)

document.addEventListener('turbolinks:load', () => {
	Vue.http.headers.common['X-CSRF-Token'] = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
	var newsletterObject = function() {
		this.subject = ''
		this.content = ''
		this.mail_to_list = []
		this.mail_cc_list = []
		this.mail_bcc_list = []
	}
	var app = new Vue({
		el: "#newsletters",
		data: {
			test: [],
			newsletters: [],
			newsletter: new newsletterObject(),
			editingCache: new newsletterObject(),
			editingKey: -1,
			errors: new newsletterObject(),
			addNewsletter: false
		},
		components: {
			InputTag
		},
		created: function() {
			var that = this
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
				var valid = false;
				valid = this.checkAllValid()
				if (valid) {
					this.$http.post('/newsletters', {
						newsletter: this.newsletter
					}).then(response => {
						that.errors = new newsletterObject()
						that.newsletter = new newsletterObject()
						that.newsletters.push(response.data)
						that.editingKey = -1
						that.addNewsletter = false
					}, response => {
						that.errors = JSON.parse(response.bodyText)
					})
				}

			},
			cancelNewsletter: function() {
				this.editingKey = -1
				this.newsletter = new newsletterObject()
				this.addNewsletter = false
				this.errors = new newsletterObject()
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
					that.errors = new newsletterObject()
					that.newsletters[key] = this.editingCache
					that.editingKey = -1
				}, response => {
					that.errors = JSON.parse(response.bodyText)
				})
			},
			// destroy Newletter
			destroyNewsletter: function(newsletter) {
				var that = this
				var destroy = confirm("Are you Sure?")
				if (destroy) {
					this.$http.delete(`/newsletters/${newsletter.id}`, {
						newsletter: newsletter
					}).then(response => {
						that.errors = new newsletterObject()
						this.newsletters.splice(this.newsletters.indexOf(newsletter), 1);
					}, response => {
						that.errors = JSON.parse(response.bodyText)
					})
				}

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
					console.log(that.errors)
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
					newsletter.message = response.body.table.message + " response : " + response.body.table.code
				}
			},
			validEmail: function(maillist, from) {
				var validRegExp = /^\w+((-\w+)|(\.\w+))*\@[A-Za-z0-9]+((\.|-)[A-Za-z0-9]+)*\.[A-Za-z0-9]+$/
				var emails = maillist
				var valid = true;
				for (var n = 0; n < emails.length; n++) {
					var mail = emails[n].trim()
					if (mail.search(validRegExp) === -1 && mail !== '') {
						valid = false;
						this.errors[from] = 'Invalid Email Address'
					}
				}
				if (valid) {
					this.errors[from] = ''
				}

				return valid
			},
			checkblank: function(inputText, from) {
				console.log(inputText)
				console.log(from)

				if ((inputText === '') || (inputText === null) || (inputText.length === 0)) {
					this.errors[from] = (typeof(inputText) === "object") ? "can not be blank, press enter key to finish" : "can not be blank"
					return false
				} else {
					this.errors[from] = ""
					return true
				}
			},
			checkAllValid: function() {
				var valid = false
				this.checkblank(this.newsletter.mail_to_list, 'mail_to_list')
				this.checkblank(this.newsletter.subject, 'subject')
				this.checkblank(this.newsletter.content, 'content')
				valid = (this.checkblank(this.newsletter.mail_to_list, 'mail_to_list') &&
					this.checkblank(this.newsletter.subject, 'subject') &&
					this.checkblank(this.newsletter.content, 'content'))

				return valid
			}

		}

	})

})
