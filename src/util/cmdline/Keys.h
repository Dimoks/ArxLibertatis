/*
 * Copyright 2013-2022 Arx Libertatis Team (see the AUTHORS file)
 *
 * This file is part of Arx Libertatis.
 *
 * Original source is copyright 2010 - 2011. Alexey Tsoy.
 * http://sourceforge.net/projects/interpreter11/
 *
 * Boost Software License - Version 1.0 - August 17th, 2003
 *
 * Permission is hereby granted, free of charge, to any person or organization
 * obtaining a copy of the software and accompanying documentation covered by
 * this license (the "Software") to use, reproduce, display, distribute,
 * execute, and transmit the Software, and to prepare derivative works of the
 * Software, and to permit third-parties to whom the Software is furnished to
 * do so, all subject to the following:
 *
 * The copyright notices in the Software and this entire statement, including
 * the above license grant, this restriction and the following disclaimer,
 * must be included in all copies of the Software, in whole or in part, and
 * all derivative works of the Software, unless such copies or derivative
 * works are solely in the form of machine-executable object code generated by
 * a source language processor.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE, TITLE AND NON-INFRINGEMENT. IN NO EVENT
 * SHALL THE COPYRIGHT HOLDERS OR ANYONE DISTRIBUTING THE SOFTWARE BE LIABLE
 * FOR ANY DAMAGES OR OTHER LIABILITY, WHETHER IN CONTRACT, TORT OR OTHERWISE,
 * ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 */

#ifndef ARX_UTIL_CMDLINE_KEYS_H
#define ARX_UTIL_CMDLINE_KEYS_H

#include <vector>

namespace util::cmdline {

/*!
 * Default option informations storage.
 *
 * This class is used as default type to store the name of an option,
 * its alternative names and description.
 */
template <typename StringType>
class key_type : std::vector<StringType> {
	
	typedef std::vector<StringType> super_t;
	
public:
	
	typedef typename super_t::value_type value_type;
	typedef typename super_t::const_iterator const_iterator;
	typedef typename super_t::iterator iterator;
	
	using super_t::front;
	using super_t::empty;
	using super_t::begin;
	using super_t::end;
	using super_t::erase;
	
	explicit key_type(const value_type & v)
		: m_argCount(0)
		, m_argNames(nullptr)
		, m_argOptional(false)
	{
		(*this)(v);
	}
	
	key_type & operator()(const value_type & v) {
		if(!v.empty())
			super_t::push_back(v);
		return *this;
	}
	
	key_type & description(const value_type & d) {
		m_description = d;
		return *this;
	}
	
	value_type get_description() const {
		return m_description;
	}
	
	key_type & arg_count(size_t argCount) {
		m_argCount = argCount;
		return *this;
	}
	
	size_t get_arg_count() const {
		return m_argCount;
	}
	
	bool has_args() const {
		return m_argCount != 0;
	}
	
	key_type & arg_names(const char * argNames) {
		m_argNames = argNames;
		return *this;
	}
	
	const char * get_arg_names() const {
		return m_argNames;
	}
	
	bool has_arg_names() const {
		return m_argNames != nullptr;
	}
	
	key_type & arg_optional(const bool argOptional) {
		m_argOptional = argOptional;
		return *this;
	}
	
	bool is_arg_optional() const {
		return m_argOptional;
	}
	
private:
	
	StringType   m_description;
	size_t       m_argCount;
	const char * m_argNames;
	bool         m_argOptional;
	
};

} // namespace util::cmdline

#endif // ARX_UTIL_CMDLINE_KEYS_H
