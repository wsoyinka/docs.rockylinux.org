import { graphql, Link, useStaticQuery } from "gatsby";
import { MDXRenderer } from "gatsby-plugin-mdx";
import { MDXProvider } from "@mdx-js/react";
import * as React from "react";
import Page from "../components/Page";

const components = { Link };

export default ({ pageContext: { frontmatter, headings, body } }) => {
    return (
        <Page meta={{ title: frontmatter.title }}>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                <div>
                    <h4 className="text-lg mb-2 font-bold">Manuals</h4>
                    <p>Coming soon</p>
                </div>
                <div className="col-span-2">
                    <div className="mb-6">
                        <h1 className="text-4xl dark:text-white">{ frontmatter.title }</h1>
                    </div>
                    <div className="bg-white dark:bg-gray-700 dark:border-gray-700 p-4 border border-gray-400 mb-6" style={{ maxWidth: '300px', width: '100%' }}>
                        <b className="mb-2">Page Contents</b>
                        <ul className="list-disc list-inside pl-4">
                        {headings.items.map(({ title, url }) => (
                            <li key={url}><a className="text-green-500 underline" href={url}>{title}</a></li>
                        ))}
                        </ul>
                    </div>
                    <div className="prose max-w-full dark-mode:prose-dark dark:text-gray-300 pb-10">
                        <MDXProvider components={components}>
                            <MDXRenderer>{ body }</MDXRenderer>
                        </MDXProvider>
                    </div>
                </div>
            </div>
        </Page>
    );
};